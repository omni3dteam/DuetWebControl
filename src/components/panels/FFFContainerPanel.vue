<template>
	<v-row :dense="$vuetify.breakpoint.mobile">
		<v-col cols="12" sm="12" md="7" lg="6" xl="6">
			<status-panel></status-panel>
		</v-col>

		<v-col cols="12" sm="12" md="5" lg="6" xl="6">
			<tools-panel></tools-panel>
		</v-col>
	</v-row>
</template>

<script>
'use strict'

import { mapGetters } from 'vuex'

export default {
	computed: {
		...mapGetters('machine', ['hasTemperaturesToDisplay'])
	}
}
</script>