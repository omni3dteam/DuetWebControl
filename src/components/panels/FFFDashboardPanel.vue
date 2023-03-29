<template>
	<v-row :dense="$vuetify.breakpoint.mobile">
		<v-col>

			<v-row v-if="isFFForUnset" class="hidden-md-and-up">
				<v-col>
					<extrude-panel></extrude-panel>
				</v-col>
			</v-row>

			<v-row>
				<v-col>
					<movement-panel class="mb-2"></movement-panel>
				</v-col>
				<v-col class="hidden-sm-and-down"  cols="5">
					<v-row v-if="isFFForUnset">
						<v-col>
							<extrude-panel></extrude-panel>
						</v-col>
					</v-row>
					<v-row>
						<v-col>
							<fan-panel></fan-panel>
						</v-col>
					</v-row>
				</v-col>
			</v-row>

			<v-row class="hidden-md-and-up">
				<v-col>
					<fan-panel></fan-panel>
				</v-col>
			</v-row>
		</v-col>

		<v-col class="hidden-lg-and-down" sm="3" md="3" lg="3" xl="3">
			<macro-list></macro-list>
		</v-col>
	</v-row>
</template>

<script>
'use strict'

import { mapState, mapGetters } from 'vuex'

import { MachineMode } from '@/store/machine/modelEnums'

export default {
	computed: {
		...mapState('machine/model', {
			fans: state => state.fans,
			atxPower: state => state.state.atxPower,
			machineMode: state => state.state.machineMode
		}),
		...mapGetters(['uiFrozen']),
		...mapGetters('machine/model', ['currentTool']),
		isFFForUnset() {
			return !this.machineMode || (this.machineMode === MachineMode.fff);
		},
		showATXPanel() {
			//return !this.isFFForUnset && this.atxPower !== null;
			return false;
		},
		showFansPanel() {
			return (this.currentTool && this.currentTool.fans.length > 0) || this.fans.some(fan => fan && !fan.thermostatic.control);
		}
	}
}
</script>
