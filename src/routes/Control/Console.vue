<template>
	<v-row :dense="$vuetify.breakpoint.mobile">
		<v-col cols="12" class="pt-1">
			<code-input solo></code-input>
		</v-col>
		<v-col cols="12">
			<event-list></event-list>
		</v-col>
	</v-row>
</template>

<script>
'use strict'

import { mapMutations } from 'vuex'

import { registerRoute } from '..'

export default {
	install() {
		// Register a route via Control -> Console
		registerRoute(this, {
			Settings: {
				Console: {
					icon: 'mdi-code-tags',
					caption: 'menu.control.console',
					path: '/Console',
					//condition: () => false
				}
			}
		});
	},
	methods: mapMutations(['hideCodeReplyNotifications', 'showCodeReplyNotifications']),
	activated() {
		this.hideCodeReplyNotifications();
	},
	deactivated() {
		this.showCodeReplyNotifications();
	}
}
</script>
