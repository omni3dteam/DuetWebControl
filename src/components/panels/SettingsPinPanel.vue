<!-- TODO: On enter - get current network status with M587 and assign values to settings.network and fill all fields -->



<template>
	<v-card outlined>
		<v-card-title class="pb-0">
			{{ $t('panel.settingsPin.caption') }}
		</v-card-title>

		<v-card-text>
		<v-form ref="pinChange">
			<v-row :dense="$vuetify.breakpoint.mobile">


				<v-col cols="12" lg="6" xl="6">
					<v-row no-gutters>
					<v-text-field
						v-model="currentPin"
						:append-icon="showCurrentPin ? 'mdi-eye' : 'mdi-eye-off'"
						:type="showCurrentPin ? 'text' : 'password'"
						:label="$t('panel.settingsPin.currentPin')" 
						@click:append="showCurrentPin = !showCurrentPin"
						></v-text-field>
					</v-row>
					<v-row  no-gutters>
					<v-text-field
						v-model="newPin"
						:append-icon="showNewPin ? 'mdi-eye' : 'mdi-eye-off'"
						:rules="[rules.required, rules.digitsOnly, rules.len]"
						:type="showNewPin ? 'text' : 'password'"
						:label="$t('panel.settingsPin.newPin')" 
						@click:append="showNewPin = !showNewPin"
						></v-text-field>
					</v-row>
					<v-row  no-gutters>
					<v-text-field
						v-model="retypePin"
						:append-icon="showRetypePin ? 'mdi-eye' : 'mdi-eye-off'"
						:rules="[rules.required, rules.digitsOnly, rules.len]"
						:type="showRetypePin ? 'text' : 'password'"
						:label="$t('panel.settingsPin.retypePin')" 
						@click:append="showRetypePin = !showRetypePin"
						></v-text-field>
					</v-row>
					<v-row no-gutters>
						<v-btn color="info" @click="send">
							<v-icon class="mr-2">mdi-send</v-icon> {{ $t("panel.settingsPin.updatePin") }}
						</v-btn>
					</v-row>
				</v-col>

				<v-col cols="12" lg="6" xl="6">
					<v-select v-model="screenLock" :items="screenLockItems" :label="$t('panel.settingsPin.lockScreenAfter')" hide-details=""></v-select>
				</v-col>

			</v-row>
		</v-form>
		</v-card-text>
	</v-card>
</template>

<script>
'use strict'

import { mapState, mapMutations, mapActions } from 'vuex'

export default {
	computed: {
		...mapState(['settings']),
		...mapState('settings', ['auth','autoLogout']),
		currentRoute() {
			return this.$route
		},
		screenLockItems() {
			return [
				{text:"10 s", value: 10000},
				{text:"30 s", value: 30000},
				{text:"1 min", value: 60000},
				{text:"3 min", value: 180000},
				{text:"5 min", value: 300000},
				{text:"10 min", value: 600000},
				{text:"30 min", value: 1800000},
				{text: this.$t("panel.settingsPin.never"), value:0}
			];
		},
		screenLock: {
			get() {
				if (this.autoLogout.enabled) {
					return this.autoLogout.timeout;
				} else {
					return 0;
				}
			},
			set(value) {
				if (value === 0) {
					this.update({ autoLogout: {enabled: false}});
				} else {
					this.update({ autoLogout: {enabled: true}});
					this.update({ autoLogout: {timeout: value}});
				}
			}
		}
	},
	data() {
		return {
			showCurrentPin: false,
			showNewPin: false,
			showRetypePin: false,
			rules: {
				required: value => !!value || this.$t("panel.settingsPin.rules.required"),
				digitsOnly: v => /(^\d+$)/.test(v) || this.$t("panel.settingsPin.rules.digitsOnly"),
				len: v => (v.length >= 4 && v.length <= 8) || this.$t("panel.settingsPin.rules.chars", [4,8]),
			},
			currentPin: '',
			newPin: '',
			retypePin: ''
		}
	},
	mounted() {
		this.clearPins();
	},
	methods: {
		...mapActions('machine', ['sendCode']),
		...mapMutations('settings', ['update']),
		send() {
			// validate current PIN
			if (this.currentPin !== this.auth.pin) {
				this.$makeNotification('error', 'PIN error', 'Wrong current PIN',5000);
				this.clearPins();
			} else if (this.newPin === '' ) {
				this.$makeNotification('error','PIN error','New PIN is required',5000);
				this.clearPins();
			} else if ( !/(^\d+$)/.test(this.newPin) ) {
				this.$makeNotification('error','PIN error','Only digits 0-9 are allowed',5000);
				this.clearPins();
			} else if ( this.newPin.length < 4 || this.newPin.length > 8 ) {
				this.$makeNotification('error','PIN error','PIN mus be 4 - 8 characters long',5000);
				this.clearPins();
			} else if (this.newPin !== this.retypePin) {
				this.$makeNotification('error', 'PIN error', 'New and retyped PIN does not match!',5000);
				this.clearPins();
			} else {
				this.update({auth: { pin: this.newPin }})
				this.$makeNotification('success', 'PIN changed successfully',"",5000);
				
			}
		},
		clearPins() {
			this.currentPin = '';
			this.newPin = '',
			this.retypePin = '';
			this.$refs.pinChange.resetValidation()
		}
	},
	watch: {
		currentRoute() {
			//clear entries if route has been changed
			this.clearPins();
		}
	}
}
</script>
