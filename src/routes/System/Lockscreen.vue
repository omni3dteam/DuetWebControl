<template>

    <v-sheet
    class="d-flex align-center justify-center flex-wrap text-center mx-auto"
    elevation="4"
    height="500"
    rounded
    max-width="800"
    width="100%"
    >
    <div>
		<v-icon size="x-large">mdi-lock</v-icon>
    	<h3 class="text-h4 ma-4">
            {{ $t('panel.lockScreen.caption') }}
        </h3>
		<p class="mb-4">
            {{ $t('panel.lockScreen.description',['OK']) }}
      	</p>


        <v-container style="width:300px">
            <v-row>
            <v-col cols="12">
            <v-text-field 
                readonly
                label="PIN"
                v-model="pin"
                :append-icon="showPin ? 'mdi-eye' : 'mdi-eye-off'"
                :type="showPin ? 'text' : 'password'"
                @click:append="togglePin()"
            ></v-text-field>                
            </v-col>
            <v-col cols="4" v-for="i in [1,2,3,4,5,6,7,8,9]" :key="i">
                <v-btn width="100%" class="py-2" @click="pinDigit(i)">
                    {{ i }}
                </v-btn>
            </v-col>
            <v-col cols="4">
                <v-btn width="100%" class="py-2" @click="pinClear()">
                    <v-icon>mdi-backspace</v-icon>
                </v-btn>
            </v-col>
            <v-col cols="4">
                <v-btn width="100%" class="py-2" @click="pinDigit(0)">
                    0
                </v-btn>
            </v-col>
            <v-col cols="4">
                <v-btn width="100%" class="py-2" @click="checkPin()">
                    <v-progress-circular indeterminate v-if="unlockProgress"></v-progress-circular>
                    <v-card-text v-else>
                        {{  $t('generic.ok') }}
                    </v-card-text>
                </v-btn>
            </v-col>
            </v-row>
        </v-container>
    </div>
  </v-sheet>

</template>

<script>
'use strict';

import { registerRoute } from '..'
import { mapState } from 'vuex'


export default {
    computed: {
        ...mapState('settings', ['auth'])
    },
    install() {
        // Register a route via System -> lock
        registerRoute(this, {
            System: {
                Lockscreen: {
                    icon: 'mdi-lock',
                    caption: 'menu.system.lock',
                    path: '/Lock'
                }
            }
        });
    }, 
    data() {
        return {
            pin:"",
            showPin: false,
            unlockProgress: false
        }
    },
    methods: {
        togglePin() {
            this.showPin = !this.showPin;
        },
        checkPin() {
            if (this.pin == this.auth.pin) {
                this.unlockProgress = true;
                this.$router.push('/');
                this.unlockProgress = false;
            } else {
                //check service codes
                const serviceCodeEntry = this.auth.serviceCodes.filter((sc) => this.pin == sc.pin);
                if (serviceCodeEntry.length > 0) {
                    this.unlockProgress = true;
                    this.$router.push(serviceCodeEntry[0].route);
                } else {
                    this.$makeNotification('error', this.$t('error.invalidPassword'), "",5000);
                }
            }
            this.pin = "";  
        },
        pinDigit(i) {
            this.pin += i;
        },
        pinClear() {
            this.pin = "";
        }
    }
};
</script>
