/*
 * qube - Qt Creator BareMetal QBS Templates for STM32CubeMX
 *
 * Copyright (c) 2017-2018 0xebef, all rights reserved, https://github.com/0xebef
 *
 * License: MIT
 */

function generate_build_path(filename) {
    var build_type_index = filename.toLowerCase().indexOf('-debug');
    var build_type = '';

    if (build_type_index >= 0) {
        build_type = 'debug';
    } else {
        build_type_index = filename.toLowerCase().indexOf('-release');
        build_type = 'release';
    }

    if (build_type_index >= 0) {
        return '../../../../bin/' + build_type;
    }

    return '/tmp/';
}
