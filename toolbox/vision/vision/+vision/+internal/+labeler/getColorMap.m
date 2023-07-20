function cMap=getColorMap(displaySource)






    if strcmpi(displaySource,'pixel')

        colorVal=[
        0.0000,0.4470,0.7410
        0.8500,0.3250,0.0980
        0.9290,0.6940,0.1250
        0.4940,0.1840,0.5560
        0.4660,0.6740,0.1880
        0.3010,0.7450,0.9330
        0.6350,0.0780,0.1840
        1.0000,0,0
        0,1.0000,0
        1.0000,0.1034,0.7241
        1.0000,0.8276,0
        0.5172,0.5172,1.0000
        0,1.0000,0.7586
        0,0.5172,0.5862
        0.5862,0.8276,0.3103
        0.9655,0.6207,0.8621
        0.8276,0.0690,1.0000
        0.9655,0.0690,0.3793
        1.0000,0.7586,0.5172
        0.5517,0.6552,0.4828
        0.9655,0.5172,0.0345
        0.5172,0.4483,0
        0.4483,0.9655,1.0000
        0.6207,0.7586,1.0000
        0.4483,0.3793,0.4828
        0,0.3103,1.0000
        0.8276,1.0000,0
        0.7241,0.3103,0.8276
        0.9310,1.0000,0.6897
        1.0000,0.4828,0.3793
        0.2759,1.0000,0.4828
        0.0690,0.6552,0.3793
        0.8276,0.6552,0.6552
        0.8276,0.3103,0.5172
        0.1724,0.3793,0.2759
        0,0.5862,0.9655
        0.6552,0.3448,0.0345
        0.4483,0.3793,0.2414
        0.0345,0.5862,0
        0.6207,0.4138,0.7241
        1.0000,1.0000,0.4483
        0.6552,0.9655,0.7931
        0.5862,0.6897,0.7241
        0.6897,0.6897,0.0345
        0.0046,0.1062,0.6878
        0.0154,0.7302,0.0550
        0.0155,0.7549,0.5054
        0.0287,0.9398,0.1002
        0.0292,0.3225,0.2060
        0.0305,0.3502,0.6628
        0.0424,0.9937,0.6754
        0.0430,0.3439,0.8507
        0.0497,0.1904,0.1673
        0.8147,0.6443,0.4229
        0.9058,0.3786,0.0942
        0.1270,0.8116,0.5985
        0.9134,0.5328,0.4709
        0.6324,0.3507,0.6959
        0.0975,0.9390,0.6999
        0.2785,0.8759,0.6385
        0.5469,0.5502,0.0336
        0.9575,0.6225,0.0688
        0.9649,0.5870,0.3196
        0.1576,0.2077,0.5309
        0.9706,0.3012,0.6544
        0.9572,0.4709,0.4076
        0.4854,0.2305,0.8200
        0.8003,0.8443,0.7184
        0.1419,0.1948,0.9686
        0.4218,0.2259,0.5313
        0.9157,0.1707,0.3251
        0.7922,0.2277,0.1056
        0.9595,0.4357,0.6110
        0.6557,0.3111,0.7788
        0.0357,0.9234,0.4235
        0.8491,0.4302,0.0908
        0.9340,0.1848,0.2665
        0.6787,0.9049,0.1537
        0.7577,0.9797,0.2810
        0.7431,0.4389,0.4401
        0.3922,0.1111,0.5271
        0.6555,0.2581,0.4574
        0.1712,0.4087,0.8754
        0.7060,0.5949,0.5181
        0.0318,0.2622,0.9436
        0.2769,0.6028,0.6377
        0.0462,0.7112,0.9577
        0.0971,0.2217,0.2407
        0.8235,0.1174,0.6761
        0.6948,0.2967,0.2891
        0.3171,0.3188,0.6718
        0.9502,0.4242,0.6951
        0.0344,0.5079,0.0680
        0.4387,0.0855,0.2548
        0.3816,0.2625,0.2240
        0.7655,0.8010,0.6678
        0.7952,0.0292,0.8444
        0.1869,0.9289,0.3445
        0.4898,0.7303,0.7805
        0.4456,0.4886,0.6753
        0.6463,0.5785,0.0067
        0.7094,0.2373,0.6022
        0.7547,0.4588,0.3868
        0.2760,0.9631,0.9160
        0.6797,0.5468,0.0012
        0.6551,0.5211,0.4624
        0.1626,0.2316,0.4243
        0.1190,0.4889,0.4609
        0.4984,0.6241,0.7702
        0.9597,0.6791,0.3225
        0.3404,0.3955,0.7847
        0.5853,0.3674,0.4714
        0.2238,0.9880,0.0358
        0.7513,0.0377,0.1759
        0.2551,0.8852,0.7218
        0.5060,0.9133,0.4735
        0.6991,0.7962,0.1527
        0.8909,0.0987,0.3411
        0.9593,0.2619,0.6074
        0.5472,0.3354,0.1917
        0.1386,0.6797,0.7384
        0.1493,0.1366,0.2428
        0.2575,0.7212,0.9174
        0.8407,0.1068,0.2691
        0.2543,0.6538,0.7655
        0.8143,0.4942,0.1887
        0.2435,0.7791,0.2875
        0.9293,0.7150,0.0911
        0.3500,0.9037,0.5762
        0.1966,0.8909,0.6834
        0.2511,0.3342,0.5466
        0.6160,0.6987,0.4257
        0.4733,0.1978,0.6444
        0.3517,0.0305,0.6476
        0.8308,0.7441,0.6790
        0.5853,0.5000,0.6358
        0.5497,0.4799,0.9452
        0.9172,0.9047,0.2089
        0.2858,0.6099,0.7093
        0.7572,0.6177,0.2362
        0.7537,0.8594,0.1194
        0.3804,0.8055,0.6073
        0.5678,0.5767,0.4501
        0.0759,0.1829,0.4587
        0.0540,0.2399,0.6619
        0.5308,0.8865,0.7703
        0.7792,0.0287,0.3502
        0.9340,0.4899,0.6620
        0.1299,0.1679,0.4162
        0.5688,0.9787,0.8419
        0.4694,0.7127,0.8329
        0.0119,0.5005,0.2564
        0.3371,0.4711,0.6135
        0.1622,0.0596,0.5822
        0.7943,0.6820,0.5407
        0.3112,0.0424,0.8699
        0.5285,0.0714,0.2648
        0.1656,0.5216,0.3181
        0.6020,0.0967,0.1192
        0.2630,0.8181,0.9398
        0.6541,0.8175,0.6456
        0.6892,0.7224,0.4795
        0.7482,0.1499,0.6393
        0.4505,0.6596,0.5447
        0.0838,0.5186,0.6473
        0.2290,0.9730,0.5439
        0.9133,0.6490,0.7210
        0.1524,0.8003,0.5225
        0.8258,0.4538,0.9937
        0.5383,0.4324,0.2187
        0.9961,0.8253,0.1058
        0.0782,0.0835,0.1097
        0.4427,0.1332,0.0636
        0.1067,0.1734,0.4046
        0.9619,0.3909,0.4484
        0.0046,0.8314,0.3658
        0.7749,0.8034,0.7635
        0.8173,0.0605,0.6279
        0.8687,0.3993,0.7720
        0.0844,0.5269,0.9329
        0.3998,0.4168,0.9727
        0.2599,0.6569,0.1920
        0.8001,0.6280,0.1389
        0.4314,0.2920,0.6963
        0.9106,0.4317,0.0938
        0.1818,0.0155,0.5254
        0.2638,0.9841,0.5303
        0.1455,0.1672,0.8611
        0.1361,0.1062,0.4849
        0.8693,0.3724,0.3935
        0.5797,0.1981,0.6714
        0.5499,0.4897,0.7413
        0.1450,0.3395,0.5201
        0.8530,0.9516,0.3477
        0.6221,0.9203,0.1500
        0.3510,0.0527,0.5861
        0.5132,0.7379,0.2621
        0.4018,0.2691,0.0445
        0.0760,0.4228,0.7549
        0.2399,0.5479,0.2428
        0.1233,0.9427,0.4424
        0.1839,0.4177,0.6878
        0.2400,0.9831,0.3592
        0.4173,0.3015,0.7363
        0.0497,0.7011,0.3947
        0.9027,0.6663,0.6834
        0.9448,0.5391,0.7040
        0.4909,0.6981,0.4423
        0.4893,0.6665,0.0196
        0.3377,0.1781,0.3309
        0.9001,0.1280,0.4243
        0.3692,0.9991,0.2703
        0.1112,0.1711,0.1971
        0.7803,0.0326,0.8217
        0.3897,0.5612,0.4299
        0.2417,0.8819,0.8878
        0.4039,0.6692,0.3912
        0.0965,0.1904,0.7691
        0.1320,0.3689,0.3968
        0.9421,0.4607,0.8085
        0.9561,0.9816,0.7551
        0.5752,0.1564,0.3774
        0.0598,0.8555,0.2160
        0.2348,0.6448,0.7904
        0.3532,0.3763,0.9493
        0.8212,0.1909,0.3276
        0.0154,0.4283,0.6713
        0.0430,0.4820,0.4386
        0.1690,0.1206,0.8335
        0.6491,0.5895,0.7689
        0.7317,0.2262,0.1673
        0.6477,0.3846,0.8620
        0.4509,0.5830,0.9899
        0.5470,0.2518,0.5144
        0.2963,0.2904,0.8843
        0.7447,0.6171,0.5880
        0.1890,0.2653,0.1548
        0.6868,0.8244,0.1999
        0.1835,0.9827,0.4070
        0.3685,0.7302,0.7487
        0.6256,0.3439,0.8256
        0.7802,0.5841,0.7900
        0.0811,0.1078,0.3185
        0.9294,0.9063,0.5341
        0.7757,0.8797,0.0900
        0.4868,0.8178,0.1117
        0.4359,0.2607,0.1363
        0.4468,0.5944,0.6787
        0.3063,0.0225,0.4952
        0.5085,0.4253,0.1897
        0.5108,0.3127,0.4950
        0.8176,0.1615,0.1476
        0.7948,0.1788,0.0550
        0.8507,0.9296,0.5828
        0.5606,0.6967,0.8154];
    elseif strcmpi(displaySource,'roi')
        colorVal=[
        0.5862,0.8276,0.3103
        0.5172,0.5172,1.0000
        0.6207,0.3103,0.2759
        0,1.0000,0.7586
        0,0.5172,0.5862
        0.9655,0.6207,0.8621
        0.8276,0.0690,1.0000
        0.4828,0.1034,0.4138
        0.9655,0.0690,0.3793
        1.0000,0.7586,0.5172
        0.1379,0.1379,0.0345
        0.5517,0.6552,0.4828
        0.9655,0.5172,0.0345
        0.5172,0.4883,0
        0.4483,0.9655,1.0000
        0.6207,0.7586,1.0000
        0.4483,0.3793,0.4828
        0,0.3103,1.0000
        0.8276,1.0000,0
        0.7241,0.3103,0.8276
        0.9310,1.0000,0.6897
        1.0000,0.4828,0.3793
        0.2759,1.0000,0.4828
        0.0690,0.6552,0.3793
        0.8276,0.6552,0.6552
        0.8276,0.3103,0.5172
        0.4138,0,0.7586
        0.1724,0.3793,0.4759
        0,0.5862,0.9655
        0.6552,0.3448,0.0345
        0.4483,0.3793,0.2414
        0.6207,0.4138,0.7241
        1.0000,1.0000,0.4483
        0.6552,0.9655,0.7931
        0.5862,0.6897,0.7241
        0.6897,0.6897,0.0345
        0,0.7931,1.0000
        0,0.7241,0.6552
        0.3103,0.4828,0.6897
        0.1034,0.2759,0.7586
        0.3448,0.8276,0
        0.4483,0.5862,0.2069
        0.8966,0.6552,0.2069
        0.9655,0.5517,0.5862
        0.4138,0.0690,0.5517
        0.8966,0.3793,0.7586
        0.9310,0.8276,1.0000
        0.6207,1.0000,0.6207
        1.0000,0.3103,0.9655
        0.5862,0.3793,1.0000
        0.7586,0.7241,0.3793
        0.9310,0.1724,0.2069
        0.6897,0.4138,0.5172
        0.2759,0.3924,0.3448
        0.7241,0.5172,0.3448
        0.5517,0.0345,1.0000
        0.8621,0.8276,0.6897
        0.8966,0.5862,1.0000
        0.9310,0,0.5172
        0.6897,0,0.5862];
    else
        colorVal=[
        0,0.7241,0.6552
        0.6207,0,0.2069
        0.3103,0.4828,0.6897
        0.3448,0.8276,0
        0.4483,0.5862,0.2069
        0.8966,0.6552,0.2069
        0.9655,0.5517,0.5862
        0.8966,0.3793,0.7586
        0.9310,0.8276,1.0000
        0.6207,1.0000,0.6207
        1.0000,0.3103,0.9655
        0.5862,0.3793,1.0000
        0.7586,0.7241,0.3793
        0.9310,0.1724,0.2069
        0.6897,0.4138,0.5172
        0.7241,0.5172,0.3448
        0.5517,0.0345,1.0000
        0.8621,0.8276,0.6897
        0.8966,0.5862,1.0000
        0.1034,0.7241,0.7931
        0.9310,0,0.5172
        0.6897,0,0.5862
        0.7241,0.6552,1.0000
        0.6552,0.5862,0.7586
        0.5172,0.1724,0.3103
        0.4483,0.4828,0.4483
        0.8621,0.2759,0
        0.5862,0.7931,0.4828
        0.7241,0.9310,1.0000
        0.2759,0.5172,0.2759
        0.6897,1.0000,0.3103
        0.2759,0.7931,0.3448
        0.8966,0.3448,0.4138
        0.9310,0.5517,0.2759
        0.4828,0.3103,0.0690
        0.3793,0.4483,0.7931
        0,1.0000,0.9310
        0.3103,0.5862,0.5172
        0.7241,0,0.7931
        1.0000,0.8621,0.4483];
    end

    cMap=reshape(colorVal,[1,size(colorVal)]);
end