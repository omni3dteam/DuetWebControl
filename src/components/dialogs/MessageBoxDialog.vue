<template>
	<v-dialog v-model="shown" :persistent="persistent">
		<v-card>
		<v-card-text class="pa-0" v-if="procedureStarted">
			<v-alert type="warning" class="mb-0" icon="mdi-polymer">
				<strong>Procedure in progress</strong>
			</v-alert>
		</v-card-text>
			<v-card-title class="justify-center">
				<span class="headline">
					{{ messageBox ? messageBox.title : $t('generic.noValue') }}
				</span>
			</v-card-title>

			<v-card-text>
				
				<div class="text-center mt-0 mb-8" v-if="procedureStarted">
					STEP {{ global.procedure_current_step }} / {{ global.procedure_total_steps }}
				</div>
				<!-- Main message -->
				<div class="text-center" :class="{ 'mb-6': displayedAxes.length }" v-html="messageBox ? messageBox.message : $t('generic.noValue')"></div>

				<!-- Jog control -->
				<!-- TODO Replace the following and the content in MovementPanel with an own component -->
				<v-row v-for="axis in displayedAxes" :key="axis.letter" dense align="center">
					<!-- Decreasing movements -->
					<v-col>
						<v-row no-gutters>
							<v-col v-for="index in numMoveSteps" :key="index"  :class="getMoveCellClass(index - 1)">
								<code-btn :code="getMoveCode(axis, index - 1, true)" :disabled="!canMove(axis)" no-wait block tile class="move-btn">
									<v-icon>mdi-chevron-left</v-icon> {{ axis.letter + showSign(-moveSteps(axis.letter)[index - 1]) }}
								</code-btn>
							</v-col>
						</v-row>
					</v-col>

					<!-- Current position -->
					<v-col cols="auto" class="px-3">
						<strong>
							{{ axis.letter + ' = ' + displayAxisPosition(axis) }}
						</strong>
					</v-col>

					<!-- Increasing movements -->
					<v-col>
						<v-row no-gutters>
							<v-col v-for="index in numMoveSteps" :key="index" :class="getMoveCellClass(numMoveSteps - index)">
								<code-btn :code="getMoveCode(axis, numMoveSteps - index, false)" :disabled="!canMove(axis)" no-wait block tile class="move-btn">
									{{ axis.letter + showSign(moveSteps(axis.letter)[numMoveSteps - index]) }} <v-icon>mdi-chevron-right</v-icon>
								</code-btn>
							</v-col>
						</v-row>
					</v-col>
				</v-row>

				<div class="text-center mt-8 mb-1" v-if="procedureShowParams" v-html="procedureParseParams">
				</div>

			</v-card-text>

			<v-card-actions v-if="messageBox && messageBox.mode !== 0">
				<v-spacer></v-spacer>
				<v-btn color="blue darken-1" text @click="ok">
					{{ $t(messageBox.mode === 1 ? 'generic.close' : 'generic.ok') }}
				</v-btn>
				<v-btn v-if="messageBox && messageBox.mode === 3" color="blue darken-1" text @click="cancel">
					{{ $t('generic.cancel') }}
				</v-btn>
				<v-spacer></v-spacer>
			</v-card-actions>
		</v-card>
	</v-dialog>
</template>

<script>
'use strict'

import { mapState, mapGetters, mapActions } from 'vuex'
import { MessageBoxMode } from "@/store/machine/modelEnums";

export default {
	computed: {
		...mapState('machine', ['isReconnecting']),
		...mapState('machine/model', {
			messageBox: state => state.state.messageBox,
			global: state => state.global,
			heat: state => state.heat,
			move: state => state.move
		}),
		...mapState('machine/settings', ['moveFeedrate']),
		...mapGetters('machine/settings', ['moveSteps', 'numMoveSteps']),
		procedureStarted() {
			return this.global.procedure_started;
			//return true;
		},
		procedureShowParams() {
			return this.global.procedure_started && this.global.procedure_parameters >= 0
		},
		procedureParseParams() {

			let output = "";
			
			let arg = parseInt(this.global.procedure_parameters);

			let id_t0 = (this.heat.heaters.length > 0) ? 0 : -1
			let id_t1 = (this.heat.heaters.length > 1) ? 1 : -1
			let id_b = (this.heat.bedHeaters.length > 0) ? this.heat.bedHeaters[0] : -1
			let id_ch = (this.heat.chamberHeaters.length > 0) ? this.heat.chamberHeaters[0] : -1
			
			//t0
			if (Array(0,5,6,7).includes(arg)) {
				output += `T0: ${this.currentTempOf(this.heat.heaters,id_t0)} / ${this.setTempOf(this.heat.heaters,id_t0)}  `;
			}
			//t1
			if (Array(1,5,6,7).includes(arg)) {
				output += `T1: ${this.currentTempOf(this.heat.heaters,id_t1)} / ${this.setTempOf(this.heat.heaters,id_t1)}  `;
			}

			if (arg >= 6) {
				output += `<br>`
			}

			//bed
			if (Array(2,4,6,7).includes(arg)) {
				output += `B: ${this.currentTempOf(this.heat.heaters,id_b)} / ${this.setTempOf(this.heat.heaters,id_b)}  `;
			}

			//chamber
			if (Array(3,4,7).includes(arg)) {
				output += `Ch: ${this.currentTempOf(this.heat.heaters,id_ch)} / ${this.setTempOf(this.heat.heaters,id_ch)}  `;
			}
			
			return output
		},
		displayedAxes() {
			const axisControls = this.messageBox ? this.messageBox.axisControls : 0;
			return this.move.axes.filter((axis, index) => axis.visible && ((axisControls & (1 << index)) !== 0));
		}
	},
	data() {
		return {
			shown: false,
			persistent: false
		}
	},
	methods: {
		...mapActions('machine', ['sendCode']),
		canMove(axis) {
			return axis.homed || !this.move.noMovesBeforeHoming;
		},
		displayAxisPosition(axis) {
			let position = NaN;
			if (this.displayToolPosition) {
				if (axis.drives.length > 0) {
					position = this.move.drives[axis.drives[0]].position;
				}
			} else {
				position = axis.machinePosition;
			}
			return (axis.letter === 'Z') ? this.$displayZ(position, false) : this.$display(position, 1);
		},
		getMoveCellClass(index) {
			let classes = '';
			if (index === 0 || index === 5) {
				classes += 'hidden-lg-and-down';
			}
			if (index > 1 && index < 4 && index % 2 === 1) {
				classes += 'hidden-md-and-down';
			}
			return classes;
		},
		getMoveCode(axis, index, decrementing) {
			return `M120\nG91\nG1 ${/[a-z]/.test(axis.letter) ? '\'' : ''}${axis.letter.toUpperCase()}${decrementing ? '-' : ''}${this.moveSteps(axis.letter)[index]} F${this.moveFeedrate}\nM121`;
		},
		showSign: (value) => (value > 0) ? `+${value}` : value,
		async ok() {
			this.shown = false;
			if (this.messageBox && (this.messageBox.mode === MessageBoxMode.okOnly || this.messageBox.mode === MessageBoxMode.okCancel)) {
				await this.sendCode('M292');
			}
		},
		async cancel() {
			this.shown = false;
			if (this.messageBox && (this.messageBox.mode === MessageBoxMode.okCancel)) {
				//send cancel feedback and procedure restart
				await this.sendCode('M292 P1').then(() => {this.sendCode('M1293')})
			}
		},
		currentTempOf(heaters,id) {
			if (id < 0 || heaters[id] == null) return "n/a"
			return Math.round(heaters[id].current)+" °C"
		},
		setTempOf(heaters,id) {
			if (id < 0 || heaters[id] == null ) return "n/a"
			return Math.round(heaters[id].active)+" °C"
		}
	},
	watch: {
		isReconnecting(to) {
			if (to) {
				this.shown = false;
			}
		},
		messageBox: {
			deep: true,
			handler(to) {
				this.shown = (to && to.mode !== null);
				this.persistent = (to && to.mode !== 0);
			}
		}
	}
}
</script>
