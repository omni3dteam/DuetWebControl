<!-- TODO: On enter - get current network status with M587 and assign values to settings.network and fill all fields -->



<template>
	<v-card outlined>
		<v-card-title class="pb-0">
			{{ $t('panel.settingsNetwork.caption') }}
		</v-card-title>

		<v-card-text>
			<v-row :dense="$vuetify.breakpoint.mobile">

				<!-- WiFi/Ethernet switch or WiFi enable/disable switch -->
				<v-col cols="12">
    	            <v-switch v-model="wifiEnabled" label="WiFi" hide-details class="mt-0"></v-switch>
				</v-col>


				<template v-if="wifiEnabled === true">
					<v-col cols="12" lg="6">
						<!-- Network name, hidden when WiFi module switch disabled -->
						<v-text-field v-model="ssid" :label="$t('panel.settingsNetwork.ssid')" hide-details></v-text-field>
					</v-col>
					<v-col cols="12" lg="6">
						<!-- Network password, hidden when WiFi module switch disabled -->
						<v-text-field
							v-model="pass"
							:append-icon="show ? 'mdi-eye' : 'mdi-eye-off'"
							:rules="[rules.required, rules.min]"
							:type="show ? 'text' : 'password'"
							:label="$t('panel.settingsNetwork.pass')" 
							hint="At least 8 characters"
							@click:append="show = !show"
							></v-text-field>
					</v-col>
				</template>
				



                <!-- Static IP switch -->
				<v-col cols="12">
					<v-switch v-model="staticIp" :label="$t('panel.settingsNetwork.staticIp')" hide-details class="mt-0"></v-switch>
				</v-col>

				<template v-if="staticIp === true">
					<v-col cols="12" lg="4">
						<!-- IP address field -->
						<v-text-field v-model="ip" :label="$t('panel.settingsNetwork.ip')" hide-details></v-text-field>
					</v-col>
					<v-col cols="12" lg="4">
						<!-- Netmask field -->
						<v-text-field v-model="netmask" :label="$t('panel.settingsNetwork.netmask')" hide-details></v-text-field>
					</v-col>
					<v-col cols="12" lg="4">
						<!-- Gateway field -->
						<v-text-field v-model="gateway" :label="$t('panel.settingsNetwork.gateway')" hide-details></v-text-field>
					</v-col>
				</template>

                <!-- Save/Confirm button somewhere on the bottom -->
				<!-- :disabled - WiFi enabled && SSID empty || StaticIP enabled && any field empty -->
				<!-- :loading - doingGcode??? -->
				<v-btn color="info" @click="send">
					<v-icon class="mr-2">mdi-send</v-icon> {{ $t('input.code.send') }} 
				</v-btn>
			</v-row>
		</v-card-text>
	</v-card>
</template>

<script>
'use strict'

import { mapState, mapMutations, mapActions } from 'vuex'

export default {
	computed: {
		...mapState(['settings']),
		...mapState('machine/model', ['network']),
		...mapState(['selectedMachine'])
	},
	data() {
		return {
			code: '',
			show: false,
			rules: {
				required: value => !!value || 'Required.',
				min: v => v.length >= 8 || 'Min 8 characters',
				//TODO: add translations
			},
			staticIp: false,
			wifiEnabled: true,
			ssid: '',
			pass: '',
			ip: '',
			netmask: '',
			gateway: ''
		}
	},
	methods: {
		...mapActions('machine', ['sendCode']),
		...mapMutations('settings', ['update']),
		async send() {
			// first of all - verify IP addresses
			if (this.staticIp) {
				let ipValid = this.isIpValid(this.ip);
				let gatewayValid = this.isIpValid(this.gateway);
				let netmaskValid = this.isIpValid(this.netmask);
				if (!ipValid || !gatewayValid || !netmaskValid) {
					//show error and exit
					this.$makeNotification('error', this.$t(`panel.settingsNetwork.ipInvalid`), this.$t('panel.settingsNetwork.ipInvalid') + ":" +
					(ipValid ? "" : (" " + this.$t('panel.settingsNetwork.staticIp'))) + 
					(gatewayValid ? "" : (" " + this.$t('panel.settingsNetwork.gateway'))) + 
					(netmaskValid ? "" : (" " + this.$t('panel.settingsNetwork.netmask'))));
					return;
				}
			}
			if (this.wifiEnabled && this.pass.length < 8) {
				this.$makeNotification('error', this.$t(`panel.settingsNetwork.passErrorTitle`), this.$t(`panel.settingsNetwork.passError`));
				return;
			}


			const wifiParams = ' S"' + this.ssid + '" P"' + this.pass + '"';
			//TODO: manage password length errors
			
			// I param - IP address
			// J param - Gateway
			// K param - Netmask
			const staticIpParams = ' I"' + this.ip + '" J"' + this.gateway + '" K"' + this.netmask + '"';
			//TODO: verify IP addresses with isIpValid method and return popup showing which parameters are invalid

			
			let gcode = '';

			if (this.network.interfaces.length > 0 && this.network.interfaces[0].state === 'active') {
				//disable Ethernet module
				gcode += "M552 I0 S0\n";
			}
			if (this.network.interfaces.length > 1 && this.network.interfaces[1].state === 'active') {
				//disable WiFi module
				gcode += "M552 I1 S0\n";
			}

			if (this.wifiEnabled) {
				gcode += 'M588 S"*"\n';
			}


			if (this.wifiEnabled || this.staticIp) {
				gcode += 'M587';
				if (this.wifiEnabled) {
					gcode += wifiParams;
				}
				if (this.staticIp) {
					gcode += staticIpParams;
				}
				gcode += "\n";
			}

			if (this.wifiEnabled) {
				gcode += "M552 I1 S1\n";
			}
			else {
				gcode += "M552 I0 S1\n";
			}
			console.log(gcode);

			await this.sendCode({ code: gcode, log: false});
		},
		isIpValid(ipaddress) {
			if (/^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/.test(ipaddress)) {
				return true;
			}
			return false;
		},
		async updateValues() {
			let success = true, response, begin, end;

			try {
				response = await this.sendCode({ code: `M587`, log: false });
				success = response.indexOf('Error') === -1;
			} catch (e) {
				response = e.message;
				success = false;
			}

			// Deal with the result
			if (success) {
				//search for network name in response
				const beginStr = 'networks:\n';
				const endStr = '\nIP=';
				begin = response.indexOf(beginStr);
				if (begin > 0) {
					begin += beginStr.length;
				}
				end = response.indexOf(endStr);
				this.ssid = response.substr(begin, end-begin);
			}

			if (this.network.interfaces.length) {
				this.ip = (this.network.interfaces[1] && this.network.interfaces[1].actualIP) ? this.network.interfaces[1].actualIP : this.network.interfaces[0].actualIP;
				this.netmask = (this.network.interfaces[1] && this.network.interfaces[1].subnet) ? this.network.interfaces[1].subnet : this.network.interfaces[0].subnet;
				this.gateway = (this.network.interfaces[1] && this.network.interfaces[1].gateway) ? this.network.interfaces[1].gateway : this.network.interfaces[0].gateway;
				this.wifiEnabled = this.network.interfaces[1] && (this.network.interfaces[1].state === "active");
			}
		},
	},
	mounted() {
		this.updateValues();
	},
	watch: {
		selectedMachine() {
			this.updateValues();
		}
	}
}
</script>
