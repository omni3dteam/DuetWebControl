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
						<v-text-field v-model="pass" :label="$t('panel.settingsNetwork.pass')" hide-details></v-text-field>
					</v-col>
				</template>
				



                <!-- Static IP switch -->
				<v-col cols="12">
					<v-switch v-model="staticIp" :label="$t('panel.settingsNetwork.staticIp')" hide-details class="mt-0"></v-switch>
				</v-col>

				<template v-if="staticIp === true">
					<v-col cols="12" lg="4">
						<!-- IP address field -->
						<v-text-field v-model.number="ip" :label="$t('panel.settingsNetwork.ip')" hide-details></v-text-field>
					</v-col>
					<v-col cols="12" lg="4">
						<!-- Netmask field -->
						<v-text-field v-model.number="netmask" :label="$t('panel.settingsNetwork.netmask')" hide-details></v-text-field>
					</v-col>
					<v-col cols="12" lg="4">
						<!-- Gateway field -->
						<v-text-field v-model.number="gateway" :label="$t('panel.settingsNetwork.gateway')" hide-details></v-text-field>
					</v-col>
				</template>

                <!-- Save/Confirm button somewhere on the bottom -->
			</v-row>
		</v-card-text>
	</v-card>
</template>

<script>
'use strict'

import { mapState, mapMutations } from 'vuex'

export default {
	computed: {
		...mapState(['settings']),

		gateway: {
			get() { return this.settings.network.gateway; },
			set(value) { this.update({ network: { gateway: value } }); }
		},
		ip: {
			get() { return this.settings.network.ip; },
			set(value) { this.update({ network: { ip: value } }); }
		},
		netmask: {
			get() { return this.settings.network.netmask; },
			set(value) { this.update({ network: { netmask: value } }); }
		},
		pass: {
			get() { return this.settings.network.pass; },
			set(value) { this.update({ network: { pass: value } }); }
		},
        ssid: {
			get() { return this.settings.network.ssid; },
			set(value) { this.update({ network: { ssid: value } }); }
		},
		wifiEnabled: {
			get() { return this.settings.network.wifiEnabled; },
			set(value) { this.update({ network: { wifiEnabled: value } }); }
		},
		staticIp: {
			get() { return this.settings.network.staticIp; },
			set(value) { this.update({ network: { staticIp: value } }); }
		}
	},
	methods: {
		...mapMutations('settings', ['update'])
	}
}
</script>
