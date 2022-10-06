Config = {}

Config.UseOxInventory = true

Config.BrpFivemAppearance = true

Config.usePEFCL = false

Config.Apartments = {
    ['AltaStreetAppts'] = {
        label = "Alta Street Apartments", 
        type = "StarterApartment",
        seperateExitPoint = true,
        entrance = {x = -270.78894042969, y = -958.21881103516, z = 31.227436065674, h = 118.76303863525},
        exit = {x = -268.41479492188, y = -963.39013671875, z = 21.912317276001, h = 356.97747802734},
        exitPoint = {x = -266.36004638672, y = -955.48510742188, z = 31.227432250977, h = 118.27416992188},
        stash = {x = -268.89364624023, y = -958.93017578125, z = 21.917707443237, h = 60.0},
        wardrobe = {x = -267.76, y = -956.6, z = 21.92, l = 2.4, w = 2.8, h = 0, minZ = 20.9, maxZ = 23.22}, 
        zone = {name = 'AltaStreetAppts', x = -266.8, y = -959.7, z = 21.9, l = 8.7, w = 5.4, h = 0, minZ = 19, maxZ = 23}, 
        blip = {
            scale = 0.7,
            sprite = 475,
            colour = 32
        },
    },

    ----------------
    -- Apartments --
    ----------------
    ['4IntegrityWay'] = {
        label = "4 Integrity Way", 
        type = "Apartment",
        seperateExitPoint = true,
        entrance = {x = -43.677406311035, y = -584.69696044922, z = 38.161270141602, h = 254.36935424805},
        exit = {x = -31.511259078979, y = -594.93328857422, z = 80.030891418457, h = 250.01995849609},
        exitPoint = {x = -44.424266815186, y = -587.35302734375, z = 38.160839080811, h = 67.393547058105},
        stash = {x = -11.746654510498, y = -597.97283935547, z = 79.430206298828, h = 153.85530090332},
        wardrobe = {x = -38.2, y = -589.3, z = 78.8, l = 4.8, w = 6.4, h = 340, minZ = 77, maxZ = 80}, 
        zone = {name = '4IntegrityWay', x = 1145.3, y = -778.4, z = 7.6, l = 30.0, w = 20.0, h = 90, minZ = 55, maxZ = 60}, 
        blip = {
            scale = 0.7,
            sprite = 475,
            colour = 32
        },
    },

    ['WeazelPlazaApartments'] = {
        label = "Weazel Plaza Apartments", 
        type = "Apartment",
        seperateExitPoint = true,
        entrance = {x = -908.98883056641, y = -446.12484741211, z = 39.605274200439, h = 114.50199127197},
        exit = {x = -890.73431396484, y = -436.75045776367, z = 121.60707092285, h = 27.384859085083},
        exitPoint = {x = -906.2998046875, y = -451.72274780273, z = 39.605285644531, h = 120.24710083008},
        stash = {x = -898.38647460938, y = -440.6930847168, z = 121.61553955078, h = 113.11880493164},
        wardrobe = {x = -909.6, y = -445.4, z = 115.4, l = 4.6, w = 5.2, h = 27, minZ = 114, maxZ = 117}, 
        zone = {name = 'WeazelPlazaApartments', x = 1145.3, y = -778.4, z = 7.6, l = 30.0, w = 20.0, h = 90, minZ = 55, maxZ = 60}, 
        blip = {
            scale = 0.7,
            sprite = 475,
            colour = 32
        },
    },

    ['RichardsMajestic'] = {
        label = "Richards Majestic", 
        type = "Apartment",
        seperateExitPoint = true,
        entrance = {x = -935.89715576172, y = -378.78204345703, z = 38.961292266846, h = 114.38324737549},
        exit = {x = -907.18048095703, y = -372.34390258789, z = 109.44027709961, h = 29.907409667969},
        exitPoint = {x = -932.91668701172, y = -383.57510375977, z = 38.96129989624, h = 119.42089080811},
        stash = {x = -914.99621582031, y = -376.62802124023, z = 109.4489440918, h = 116.96913146973},
        wardrobe = {x = -926.1, y = -381.5, z = 103.2, l = 4.2, w = 5.0, h = 27, minZ = 101, maxZ = 104.2}, 
        zone = {name = 'RichardsMajestic', x = 1145.3, y = -778.4, z = 57.6, l = 30.0, w = 20.0, h = 90, minZ = 55, maxZ = 60}, 
        blip = {
            scale = 0.7,
            sprite = 475,
            colour = 32
        },
    },

    ['DelPerroHeights'] = {
        label = "Del Perro Heights", 
        type = "Apartment",
        seperateExitPoint = false,
        entrance = {x = -1447.6293945313, y = -537.32611083984, z = 34.740154266357, h = 215.23828125},
        exit = {x = -1452.2774658203, y = -540.5205078125, z = 74.044303894043, h = 40.185394287109},
        stash = {x = -1466.7415771484, y = -526.98858642578, z = 73.443618774414, h = 306.0309753418},
        wardrobe = {x = -1450.2, y = -549.3, z = 72.8, l = 4.0, w = 4.4, h = 35, minZ = 70, maxZ = 74}, 
        zone = {name = 'DelPerroHeights', x = 1145.3, y = -778.4, z = 7.6, l = 30.0, w = 20.0, h = 90, minZ = 55, maxZ = 60}, 
        blip = {
            scale = 0.7,
            sprite = 475,
            colour = 32
        },
    },

    ['TinselTowers'] = {
        label = "Tinsel Towers", 
        type = "Apartment",
        seperateExitPoint = true,
        entrance = {x = -621.08837890625, y = 46.244003295898, z = 43.591468811035, h = 186.38636779785},
        exit = {x = -602.87280273438, y = 58.898902893066, z = 98.200187683105, h = 90.942649841309},
        exitPoint = {x = -614.61468505859, y = 46.540714263916, z = 43.591468811035, h = 184.96089172363},
        stash = {x = -622.54583740234, y = 54.491561889648, z = 97.599517822266, h = 0.27685731649399},
        wardrobe = {x = -594.7, y = 55.6, z = 97.0, l = 4.4, w = 4.2, h = 0, minZ = 95, maxZ = 99}, 
        zone = {name = 'TinselTowers', x = 1145.3, y = -778.4, z = 7.6, l = 30.0, w = 20.0, h = 90, minZ = 55, maxZ = 60}, 
        blip = {
            scale = 0.7,
            sprite = 475,
            colour = 32
        },
    },

    ['EclipseTowers'] = {
        label = "Eclipse Towers", 
        type = "Apartment",
        seperateExitPoint = true,
        entrance = {x = -776.97711181641, y = 319.74661254883, z = 85.662673950195, h = 177.4141998291},
        exit = {x = -773.93316650391, y = 341.95892333984, z = 196.68617248535, h = 91.444755554199},
        exitPoint = {x = -770.62426757813, y = 319.72906494141, z = 85.662673950195, h = 177.16806030273},
        stash = {x = -764.73388671875, y = 330.80294799805, z = 196.08601379395, h = 180.05033874512},
        wardrobe = {x = -763.2, y = 329.0, z = 199.5, l = 5.2, w = 4.6, h = 0, minZ = 198, maxZ = 201}, 
        zone = {name = 'EclipseTowers', x = 1145.3, y = -778.4, z = 7.6, l = 30.0, w = 20.0, h = 90, minZ = 55, maxZ = 60}, 
        blip = {
            scale = 0.7,
            sprite = 475,
            colour = 32
        },
    },
}