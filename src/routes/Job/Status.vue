<style scoped>
.chart-height-limit {
	max-height: 320px;
}
</style>

<template>
	<div class="d-flex flex-column">
		<job-progress></job-progress>

		<v-row class="mt-0" :dense="$vuetify.breakpoint.mobile">
			<v-col order="1" order-md="1" cols="12" sm="6" md="4" lg="3" xl="2">
				<v-row align="center" :dense="$vuetify.breakpoint.mobile">
					<v-col cols="12">
						<job-control-panel></job-control-panel>
					</v-col>
					<v-col cols="12">
						<z-babystep-panel></z-babystep-panel>
					</v-col>
					<v-col class="hidden-sm-and-down">
						<job-info-panel></job-info-panel>
					</v-col>
					<v-col cols="12" class="hidden-sm-and-down">
						<speed-factor-panel></speed-factor-panel>
					</v-col>
					<v-col cols="12" class="hidden-sm-and-down">
						<extrusion-factors-panel></extrusion-factors-panel>
					</v-col>
					<v-col cols="12">
						<fans-panel></fans-panel>
					</v-col>
				</v-row>
			</v-col>

			<v-col order="0" order-md="2" cols="12" md="8" lg="5" xl="5" class="d-none d-sm-flex flex-column">
				<webcam-panel class="d-none d-md-block d-lg-none mb-5"></webcam-panel>
				
				<layer-chart class="chart-height-limit mb-5"></layer-chart>
				<temperature-chart class="mb-5"></temperature-chart>

				<v-row class="flex-grow-0 flex-shrink-1 d-none d-md-flex">
					<v-col cols="12">
						<job-estimations-panel></job-estimations-panel>
					</v-col>
					<v-col cols="12">
						<job-data-panel></job-data-panel>
					</v-col>
				</v-row>

				<v-row class="flex-grow-0 flex-shrink-1 hidden-sm-and-up mt-3">
					<v-col cols="6" md="6">
						<fans-panel></fans-panel>
					</v-col>
					<v-col cols="6" md="6">
						<speed-factor-panel></speed-factor-panel>
					</v-col>
				</v-row>
			</v-col>

			<v-col order="2" order-md="3" cols="12" sm="6" class="hidden-md-and-up">
				<v-row :dense="$vuetify.breakpoint.mobile">
					<v-col cols="12">
						<job-estimations-panel></job-estimations-panel>
					</v-col>
					<v-col cols="12">
						<job-data-panel></job-data-panel>
					</v-col>
					<v-col cols="12">
						<job-info-panel></job-info-panel>
					</v-col>
					<v-col cols="12">
						<speed-factor-panel></speed-factor-panel>
					</v-col>
					<v-col cols="12">
						<extrusion-factors-panel></extrusion-factors-panel>
					</v-col>
				</v-row>
			</v-col>

			<v-col order="4" cols="12" lg="4" xl="5" class="hidden-md-only">
				<webcam-panel></webcam-panel>
			</v-col>
		</v-row>
	</div>
</template>

<script>
'use strict'

import { registerRoute } from '..'

export default {
	install() {
		// Register a route via Job -> Status
		registerRoute(this, {
			Job: {
				Status: {
					icon: 'mdi-information',
					caption: 'menu.job.status',
					path: '/Job/Status'
				}
			}
		});
	}
}
</script>
