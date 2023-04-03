<template>
    <v-sheet>
    </v-sheet>
</template>

<script>
'use strict';

import { registerRoute } from '..'

export default {
    install() {
        // Register a route via System -> lock
        registerRoute(this, {
            System: {
                Lockscreen: {
                    icon: 'mdi-power',
                    caption: 'menu.system.shutdown',
                    path: '/Shutdown'
                }
            }
        });
    }
};
</script>
