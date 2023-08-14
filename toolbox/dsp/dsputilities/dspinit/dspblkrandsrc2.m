function varargout=dspblkrandsrc2(action)





    blk=gcbh;

    [NORM_METHOD,CLT_LENGTH,MIN,MAX]=deal(2,3,4,5);
    [MEAN,VAR,SEED]=deal(6,7,9);
    [SAMP_MODE,SAMP_TIME,SAMP_FRAME,DATA_TYPE,OUT_COMPLEX]=deal(11,12,13,14,15);

    if nargin==0
        action='dynamic';
    end

    RepMode=get_param(blk,'RepMode');

    switch action
    case 'seed'






















        ud=get_param(blk,'userdata');
        ud_old=ud;































        if isempty(ud)

            ud.Seed=get_param(blk,'rawSeed');
            ud.SeedFlag='DoNotSaveSeed';










            set_param(blk,'RepMode','Specify seed');
        else





            if(strcmp(RepMode,'Specify seed'))

                ud.Seed=get_param(blk,'rawSeed');
                ud.SeedFlag='DoNotSaveSeed';

            elseif(strcmp(RepMode,'Repeatable'))



                if strcmp(ud.SeedFlag,'DoNotSaveSeed')

                    seedVal=floor(rand(1)*100000);
                    ud.Seed=num2str(seedVal);
                    ud.SeedFlag='SaveSeed';
                end

            else


                seedVal=23113;
                ud.Seed=num2str(seedVal);
                ud.SeedFlag='DoNotSaveSeed';
            end
        end


        if~isequal(ud,ud_old)


            set_param(blk,'userdatapersistent','on');
            set_param(blk,'userdata',ud);
        end


        varargout={ud.Seed};

    case 'dynamic'





        vis=get_param(blk,'maskvisibilities');
        oldvis=vis;
        SrcType=get_param(blk,'SrcType');
        InheritMode=strcmp(get_param(blk,'Inherit'),'on');


        if strcmp(SrcType,'Gaussian')
            vis([NORM_METHOD,MEAN,VAR])={'on'};
            vis([MIN,MAX])={'off'};

            set_param(blk,'maskvisibilities',vis);
            oldvis=vis;
            NormMethod=get_param(blk,'NormMethod');
            if strcmp(NormMethod,'Sum of uniform values')
                vis(CLT_LENGTH)={'on'};
            else
                vis(CLT_LENGTH)={'off'};
            end
        else
            vis([NORM_METHOD,MEAN,VAR,CLT_LENGTH])={'off'};
            vis([MIN,MAX])={'on'};
        end


        if strcmp(RepMode,'Specify seed')
            vis(SEED)={'on'};
        else
            vis(SEED)={'off'};
        end


        if InheritMode
            vis([SAMP_MODE,SAMP_TIME,SAMP_FRAME,DATA_TYPE,OUT_COMPLEX])={'off'};
        else
            vis([SAMP_MODE,OUT_COMPLEX,DATA_TYPE])={'on'};

            set_param(blk,'maskvisibilities',vis);
            oldvis=vis;
            SampMode=get_param(blk,'SampMode');
            if strcmp(SampMode,'Discrete')
                vis([SAMP_TIME,SAMP_FRAME])={'on'};
            elseif strcmp(SampMode,'Continuous')
                vis([SAMP_TIME,SAMP_FRAME])={'off'};
            end
        end


        if(~isequal(vis,oldvis))
            set_param(blk,'maskvisibilities',vis);
        end

    otherwise
        error(message('dsp:dspblkrandsrc2:unhandledCase'));
    end


