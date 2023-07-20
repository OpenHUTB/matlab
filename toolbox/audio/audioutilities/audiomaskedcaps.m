function subsysCap=audiomaskedcaps(block)






    if~strcmpi(get_param(block,'Mask'),'on')
        DAStudio.error('Simulink:bcst:ErrOnlyMasks',mfilename);
    end

    maskType=get_param(block,'MaskType');


    [maskStr,trans]=getMaskStr(maskType,block);


    if strcmpi(get_param(block,'Mask'),'on')&&...
        strcmpi(get_param(block,'BlockType'),'SubSystem')&&...
        isSublibrary(block)
        maskStr='';
    end


    subsysCap=bcstCreateCap(maskType,maskStr,trans);



    function[subsysCapStr,trans]=getMaskStr(maskType,block)

        persistent maskTable transTable;
        if isempty(maskTable)
            [maskTable,transTable]=getMaskTable;
        end

        if isempty(maskType)||(strcmpi(get_param(block,'BlockType'),'SubSystem')&&isempty(get_param(block,'Blocks')))

            subsysCapStr='';
            trans=transTable;
        else

            findMask=find(strcmp(maskType,maskTable(:,2)));
            if~isempty(findMask)

                subsysCapStr=maskTable{findMask,1};
                trans=transTable;
            else
                DAStudio.error('Simulink:bcst:ErrMaskNotFound',maskType,mfilename);
            end
        end



        function[maskTable,transTable]=getMaskTable



            transTable.d='double';

            transTable.s='single';

            transTable.b='boolean';

            transTable.i='integer';
            transTable.is='integerSgn';
            transTable.iu='integerUns';
            transTable.depends.is='i';
            transTable.depends.iu='i';

            transTable.f='fixedpt';
            transTable.fs='fixedptSgn';
            transTable.fu='fixedptUns';
            transTable.depends.fs='f';
            transTable.depends.fu='f';

            transTable.e='enumerated';
            transTable.B='bus';

            transTable.c='codegen';
            transTable.p='production';

            transTable.m='multidimension';
            transTable.I='foreach';
            transTable.v='variablesize';
            transTable.S='symbolicdimension';
            transTable.t='string';
            transTable.z='zerocrossing';
            transTable.D='directfeedthrough';





































            maskTable={...
...
...
...
            'd;s;c;p;v;I;','audio.simulink.DynamicRangeCompressor';...
            'd;s;c;p;v;I;','audio.simulink.DynamicRangeExpander';...
            'd;s;c;p;v;I;','audio.simulink.DynamicRangeLimiter';...
            'd;s;c;p;v;I;','audio.simulink.DynamicRangeGate';...
...
            'd;s;c;p;v;I;','audio.simulink.Reverberator';...
...
            'd;s;c;p;v;I;','audio.simulink.crossover';...
            'd;s;c;p;v;I;','weightingFilter';...
            'd;s;c;p;v;I;','audio.simulink.OctaveFilter';...
            'd;s;c;p;v;I;','audio.simulink.OctaveFilterBank';...
            'd;s;c;p;v;I;','audio.simulink.GammatoneFilterBank';...
            'd;s;c;p;v;I;','audio.simulink.GraphicEQ';...
            'd;s;c;p;v;I;','audio.simulink.ParametricEQ';...
            'd;s;c;p;v;I;','audio.simulink.MultibandParametricEQ';...
            'd;s;c;p;v;I;','audio.simulink.ShelvingFilter';...
...
            'd;s;c;p;v;I;','audio.simulink.LoudnessMeter';...
            'd;s;c;p;I;','audio.simulink.VoiceActivityDetector';...
...
            'd;s;i.dsp_Fns3216u8;c.dsp_FnHostPCOnly;p;','Audio Device Reader';...
            'd;s;c;p;','audio.simulink.WavetableSynthesizer';...
            'd;s;c;p;','audio.simulink.AudioOscillator';...
...
            'd;s;c;p;I;','YAMNet Preprocess';...
            'd;s;c;p;I;','Sound Classifier';...
            'd;s;c;p;I;','YAMNet';...
            'd;s;c;p;I;','VGGish Preprocess';...
            'd;s;c;p;I;','VGGish Embeddings';...
            'd;s;c;p;I;','VGGish';...
            'd;s;c;p;I;','OpenL3 Preprocess';...
            'd;s;c;p;I;','OpenL3 Embeddings';...
            'd;s;c;p;I;','OpenL3';...
...
            'd;s;c;p;I;','Auditory Spectrogram';...
            'd;s;c;p;I;','Mel Spectrogram';...
            'd;s;c;p;I;','audio.simulink.DesignAuditoryFilterBank';...
            'd;s;c;p;I;','audio.simulink.DesignmelFilterBank';...
            'd;s;c;p;v;I;','audio.simulink.AudioDelta';...
            'd;s;c;p;I;','audio.simulink.CepstralCoefficients';...
            'd;s;c;p;I;','MFCC';...
            };




            function isSubLib=isSublibrary(block)

                sublibs={...
                };

                nameSp=[get_param(block,'Parent'),'/',get_param(block,'Name')];

                isSubLib=any(strcmp(nameSp,sublibs));


