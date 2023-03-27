<style>
.move-btn {
	padding-left: 0 !important;
	padding-right: 0 !important;
	min-width: 0;
}
</style>

<template>
	<v-card>
		<v-card-title>
			<v-icon small class="mr-1">mdi-swap-horizontal</v-icon> {{ $t('panel.movement.caption') }}

			<v-spacer></v-spacer>

			<v-menu offset-y left>
				<template #activator="{ on }">
					<v-btn v-show="visibleAxes.length" color="primary" small class="mx-0" :elevation="1" v-on="on">
						{{ $t('panel.movement.compensation') }} <v-icon>mdi-menu-down</v-icon>
					</v-btn>
				</template>

				<v-card>
					<v-list>
						<template v-show="move.compensation">
							<v-list-item>
								<v-spacer></v-spacer>
								{{ $t('panel.movement.compensationInUse', [$t(`panel.movement.compensationType.${move.compensation.type}`)]) }}
								<v-spacer></v-spacer>
							</v-list-item>

							<v-divider></v-divider>
						</template>

						<v-list-item :disabled="!canHome" @click="sendCode('G32')">
							<v-icon class="mr-1">mdi-format-vertical-align-center</v-icon> {{ $t(isDelta ? 'panel.movement.runDelta' : 'panel.movement.runBed') }}
						</v-list-item>
						<v-list-item :disabled="!move.compensation.type || move.compensation.type.indexOf('Point') === -1" @click="sendCode('M561')">
							<v-icon class="mr-1">mdi-border-none</v-icon> {{ $t('panel.movement.disableBedCompensation') }} 
						</v-list-item>

						<v-divider></v-divider>

						<v-list-item :disabled="!canHome" @click="sendCode('G29')">
							<v-icon class="mr-1">mdi-grid</v-icon> {{ $t('panel.movement.runMesh') }}
						</v-list-item>
						<v-list-item :disabled="uiFrozen" @click="showMeshEditDialog = true">
							<v-icon class="mr-1">mdi-pencil</v-icon> {{ $t('panel.movement.editMesh') }}
						</v-list-item>
						<v-list-item :disabled="uiFrozen" @click="sendCode('G29 S1')">
							<v-icon class="mr-1">mdi-content-save</v-icon> {{ $t('panel.movement.loadMesh') }}
						</v-list-item>
						<v-list-item :disabled="!isCompensationEnabled" @click="sendCode('G29 S2')">
							<v-icon class="mr-1">mdi-grid-off</v-icon> {{ $t('panel.movement.disableMeshCompensation') }}
						</v-list-item>
					</v-list>
				</v-card>
			</v-menu>
		</v-card-title>

		<v-card-text v-show="visibleAxes.length !== 0">
			<v-row class="ml-0 mb-1">
				<code-btn v-show="visibleAxes.length" color="primary" small code="G28 XY" :disabled="!canHome" :title="$t('button.home.title',['XY'])" class="ma-2">
					{{ $t('button.home.caption', [" XY"]) }}
				</code-btn>
				<code-btn v-show="visibleAxes.length" color="primary" small code="G28 Z" :disabled="!canHome" :title="$t('button.home.title', ['Z'])" class="ma-2">
					{{ $t('button.home.caption', [" Z"]) }}
				</code-btn>
			</v-row>
			<v-row>
				<v-spacer class="hidden-md-and-up"></v-spacer>
						<v-sheet class="ml-2 mb-2">
							<v-card-text class="ma-0 ml-3 pa-0">
								{{ $t("panel.movement.moveAxes", ["XY"])  }}:
							</v-card-text>
							<v-card class="pa-2 ma-2 global-control">
								<div class="pa-0 ma-0 mb-1 d-flex">
									<v-card-text class="pa-0 ma-0">
										<strong>X:</strong> {{ xypanel.x }} mm
									</v-card-text>
									<v-card-text class="pa-0 ma-0">
										<strong>Y:</strong> {{ xypanel.y }} mm
									</v-card-text>
								</div>
								<svg width="350" height="350" ref="xypanel" @click="updateCoordinates">
									<defs>
										<pattern id="grid" width="20%" height="20%">
											<rect width="20%" height="20%" fill="none" stroke="#999" />
										</pattern>
									</defs>
									<rect width="100%" height="100%" fill="url(#grid)" />
									<rect v-if="showXYPanelMessage" x="10" y="10" width="75%" height="30" rx="5" fill="#fb8c00" />
									<text v-if="showXYPanelMessage" x="20" y="30" style="fill:#FFF;">
										{{ getXYPanelMessage }}
									</text>
									<line v-if="xypanel.showCrosshair" :x1="xypanel.pxx" :x2="xypanel.pxx" y1="0%" y2="100%" :stroke="getXYPanelPointColor"></line>
									<line v-if="xypanel.showCrosshair" :y1="xypanel.pxy" :y2="xypanel.pxy" x1="0%" x2="100%" :stroke="getXYPanelPointColor"></line>
									<circle v-if="xypanel.showPoint" :cx="xypanel.pxx" :cy="xypanel.pxy" r="5" :fill="getXYPanelPointColor" />
								</svg>
							</v-card>
						</v-sheet>

				<v-spacer class="hidden-md-and-up"></v-spacer>

				<v-col align-self="center" class="hidden-xs-only">
					<v-sheet width="120" v-for="(axis, axisIndex) in getZAxes" :key="axisIndex" >	
						<!-- Decreasing movements -->
						<v-row v-for="index of indicesToShow" :key="index+'-up'">
							<code-btn :code="getMoveCode(axis, index - 1, true)" :disabled="!canMove(axis)" no-wait @contextmenu.prevent="showMoveStepDialog(axis.letter, index - 1)" block tile class="move-btn ma-2">
								<v-icon>mdi-chevron-up</v-icon> {{ axis.letter + showSign(-moveSteps(axis.letter)[index - 1]) }}
							</code-btn>
						</v-row>
						
						<!-- Spacer -->
						<v-row class="ma-5"></v-row>
						
						<!-- Increasing movements -->
						<v-row v-for="index of indicesToShow" :key="index+'-down'">
							<code-btn :code="getMoveCode(axis, numMoveSteps - index, false)" :disabled="!canMove(axis)" no-wait @contextmenu.prevent="showMoveStepDialog(axis.letter, numMoveSteps - index)" block tile class="move-btn ma-2">
								<v-icon>mdi-chevron-down</v-icon> {{ axis.letter + showSign(moveSteps(axis.letter)[numMoveSteps - index]) }}
							</code-btn>
						</v-row>
					</v-sheet>
				</v-col>
				<v-spacer class="hidden-xs-only"></v-spacer>
			</v-row>
			
			<v-row class="hidden-sm-and-up">
				<v-spacer></v-spacer>
				<v-col>
					<v-sheet width="300" v-for="(axis, axisIndex) in getZAxes" :key="axisIndex" >	
						<!-- Decreasing movements -->
						<v-row v-for="index of indicesToShow" :key="index+'-up'">
							<code-btn :code="getMoveCode(axis, index - 1, true)" :disabled="!canMove(axis)" no-wait @contextmenu.prevent="showMoveStepDialog(axis.letter, index - 1)" block tile class="move-btn ma-2">
								<v-icon>mdi-chevron-up</v-icon> {{ axis.letter + showSign(-moveSteps(axis.letter)[index - 1]) }}
							</code-btn>
						</v-row>
						
						<!-- Spacer -->
						<v-row class="ma-5"></v-row>
						
						<!-- Increasing movements -->
						<v-row v-for="index of indicesToShow" :key="index+'-down'">
							<code-btn :code="getMoveCode(axis, numMoveSteps - index, false)" :disabled="!canMove(axis)" no-wait @contextmenu.prevent="showMoveStepDialog(axis.letter, numMoveSteps - index)" block tile class="move-btn ma-2">
								<v-icon>mdi-chevron-down</v-icon> {{ axis.letter + showSign(moveSteps(axis.letter)[numMoveSteps - index]) }}
							</code-btn>
						</v-row>
					</v-sheet>
				</v-col>
				<v-spacer></v-spacer>	
			</v-row>
		</v-card-text>

		<mesh-edit-dialog :shown.sync="showMeshEditDialog"></mesh-edit-dialog>
		<input-dialog :shown.sync="moveStepDialog.shown" :title="$t('dialog.changeMoveStep.title')" :prompt="$t('dialog.changeMoveStep.prompt')" :preset="moveStepDialog.preset" is-numeric-value @confirmed="moveStepDialogConfirmed"></input-dialog>

		<v-alert :value="unhomedAxes.length !== 0" type="warning" class="mb-0">
			{{ $tc('panel.movement.axesNotHomed', unhomedAxes.length) }}
			<strong>
				{{ unhomedAxes.map(axis => axis.letter).join(', ') }}
			</strong>
		</v-alert>

		<v-alert :value="visibleAxes.length === 0" type="info">
			{{ $t('panel.movement.noAxes') }}
		</v-alert>
	</v-card>
</template>

<script>
'use strict'

import { mapState, mapGetters, mapActions, mapMutations } from 'vuex'

import { KinematicsName, StatusType } from '@/store/machine/modelEnums'

export default {
	computed: {
		...mapGetters(['isConnected', 'uiFrozen']),
		...mapState('machine/model', ['move', 'state']),
		...mapState('machine/settings', ['moveFeedrate']),
		...mapGetters('machine/settings', ['moveSteps', 'numMoveSteps']),
		//...mapActions('machine', ['sendCode']),
		isCompensationEnabled() { return this.move.compensation.type.toLowerCase() !== 'none' },
		visibleAxes() { return this.move.axes.filter(axis => axis.visible); },
		isDelta() {
			return (this.move.kinematics.name === KinematicsName.delta ||
					this.move.kinematics.name === KinematicsName.rotaryDelta);
		},
		canHome() {
			return !this.uiFrozen && (
				this.state.status !== StatusType.pausing &&
				this.state.status !== StatusType.processing &&
				this.state.status !== StatusType.resuming
			);
		},
		getXYPanelPointColor() {
			return this.$vuetify.theme.dark ? "#EEE" : "#111";
		},
		// getXYPanelTextStyle() {
		// 	return `fill:${this.getXYPanelForegroundColor()};`;
		// },
		showXYPanelMessage() {
			return this.getXYPanelState() < 0;
		},
		indicesToShow() {
			return [1,3,5];
		},
		getZAxes() { 
			return this.move.axes.filter(axis => axis.letter.toLowerCase() == 'z');
		},
		getXYPanelMessage() {

			this.updateXYPanelPoint();

			//todo i18n
			switch(this.getXYPanelState()) {
				case 0: return "<empty message>"; //should not be visible
				case -1: return this.$t('panel.movement.xypanel.notConnected');
				case -2: return this.$t('panel.movement.xypanel.cantMoveWhenPrint');
				case -3: return this.$t('panel.movement.xypanel.homeRequired');
				default: break;
			}

			return "unknown msg";
		},

		unhomedAxes() { return this.move.axes.filter(axis => axis.visible && !axis.homed); }
	},
	data() {
		return {
			showMeshEditDialog: false,
			moveStepDialog: {
				shown: false,
				axis: 'X',
				index: 0,
				preset: 0
			},
			xypanel: {
				clicked: false,
				showPoint: false,
				showCrosshair: false,
				pxx:0,
				pxy:0,
				x: 0,
				y: 0
			}
		}
	},
	methods: {
		...mapActions('machine', ['sendCode']),
		...mapMutations('machine/settings', ['setMoveStep']),
		canMove(axis) {
			return (axis.homed || !this.move.noMovesBeforeHoming) && this.canHome;
		},
		getHomeCode(axis) {
			return `G28 ${/[a-z]/.test(axis.letter) ? '\'' : ''}${axis.letter.toUpperCase()}`;
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
		showMoveStepDialog(axis, index) {
			this.moveStepDialog.axis = axis;
			this.moveStepDialog.index = index;
			this.moveStepDialog.preset = this.moveSteps(this.moveStepDialog.axis)[this.moveStepDialog.index];
			this.moveStepDialog.shown = true;
		},
		moveStepDialogConfirmed(value) {
			this.setMoveStep({ axis: this.moveStepDialog.axis, index: this.moveStepDialog.index, value });
		},
		getAxisByLetter(letter) {
			return this.move.axes.filter(axis => axis.letter.toLowerCase() == letter.toLowerCase())[0];
		},
		// getXYPanelForegroundColor() {
		// 	return this.$vuetify.theme.dark ? "#EEE" : "#111";
		// },
		getXYPanelState() {
			
			if (this.uiFrozen) return -1;
			if (!this.canHome) return -2;
			if (!this.getAxisByLetter('x').homed || !this.getAxisByLetter('y').homed) return -3;

			return 0;
		},
		updateCoordinates(event) {
			this.xypanel.clicked = true;
			
			let box = this.$refs.xypanel.getBoundingClientRect();

			//work area in mm
			var areaX = this.getAxisByLetter('x').max;
			var areaY = this.getAxisByLetter('y').max;

			console.log(`read axes max X: ${areaX} Y: ${areaY}` );

			//TODO why Omni500 returns 540x550???
			if(areaX > 500) areaX = 500;
			if(areaY > 500) areaY = 500;

			if (this.getXYPanelState() >= 0) {
				this.xypanel.pxx = event.offsetX;
				this.xypanel.pxy = event.offsetY;

				this.xypanel.x = Math.round(event.offsetX/box.width*areaX);
				this.xypanel.y = Math.round((1-(event.offsetY/box.height))*areaY);
				
				this.xypanel.showPoint = true;
				this.xypanel.showCrosshair = true;

				//TODO set F by config, not hard-coded
				this.sendCode(`G1 X${this.xypanel.x} Y${this.xypanel.y} F8000`);
				//console.log((`G1 X${this.xypanel.x} Y${this.xypanel.y} F8000`));
			// } else {
			// 	console.log('Cannot move axes XY');
			}		
			
			this.updateXYPanelPoint();
		},
		updateXYPanelPoint() {
			this.xypanel.showPoint = this.xypanel.clicked && this.getXYPanelState()>=0;
			this.xypanel.showCrosshair = this.xypanel.clicked && this.getXYPanelState()>=0;
		}
	},
	watch: {
		isConnected() {
			// Hide dialogs when the connection is interrupted
			this.showMeshEditDialog = false;
			this.moveStepDialog.shown = false;
		}
	}
}
</script>
