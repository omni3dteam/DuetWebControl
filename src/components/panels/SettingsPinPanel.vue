<!-- TODO: On enter - get current network status with M587 and assign values to settings.network and fill all fields -->



<template>
	<v-card outlined>
		<v-card-title class="pb-0">
			PIN change
		</v-card-title>

		<v-card-text>
		<v-form ref="pinChange">
			<v-row :dense="$vuetify.breakpoint.mobile">


				<v-col cols="12">
					<v-text-field
						v-model="currentPin"
						:append-icon="showCurrentPin ? 'mdi-eye' : 'mdi-eye-off'"
						:type="showCurrentPin ? 'text' : 'password'"
						label="Current PIN" 
						@click:append="showCurrentPin = !showCurrentPin"
						></v-text-field>
				</v-col>
				<v-col cols="12">
					<v-text-field
						v-model="newPin"
						:append-icon="showNewPin ? 'mdi-eye' : 'mdi-eye-off'"
						:rules="[rules.required, rules.digitsOnly, rules.len]"
						:type="showNewPin ? 'text' : 'password'"
						label="New PIN" 
						@click:append="showNewPin = !showNewPin"
						></v-text-field>
				</v-col>
				<v-col cols="12">
					<v-text-field
						v-model="retypePin"
						:append-icon="showRetypePin ? 'mdi-eye' : 'mdi-eye-off'"
						:rules="[rules.required, rules.digitsOnly, rules.len]"
						:type="showRetypePin ? 'text' : 'password'"
						label="Retype PIN" 
						@click:append="showRetypePin = !showRetypePin"
						></v-text-field>
				</v-col>
				
                <!-- Save/Confirm button somewhere on the bottom -->
				<v-btn color="info" @click="send">
					<v-icon class="mr-2">mdi-send</v-icon> {{ $t('input.code.send') }} 
				</v-btn>
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
		...mapState('settings', ['auth']),
		currentRoute() {
			return this.$route
		}
	},
	data() {
		return {
			showCurrentPin: false,
			showNewPin: false,
			showRetypePin: false,
			rules: {
				required: value => !!value || 'Required.',
				digitsOnly: v => /(^\d+$)/.test(v) || 'only digits 0-9 are allowed',
				len: v => (v.length >= 4 && v.length <= 8) || '4 - 8 characters',
				
				//TODO: add translations
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
				//console.log("send")
				//this.auth.pin = this.newPin;
				this.update({auth: { pin: this.newPin }})
				this.$makeNotification('success', 'PIN changed successfully',"");
				
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
			console.log('route changed');
			this.clearPins();
		}
	}
}
</script>
