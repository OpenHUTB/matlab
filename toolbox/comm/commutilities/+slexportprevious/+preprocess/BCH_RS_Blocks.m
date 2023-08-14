function BCH_RS_Blocks(obj)












    if isR2015aOrEarlier(obj.ver)


        bch_Blocks=findBCHblocks(obj);
        rs_Blocks=findRSblocks(obj);
        bch_rs_Blocks=[bch_Blocks;rs_Blocks];






        for i=1:length(bch_rs_Blocks)
            blk=bch_rs_Blocks{i};
            convertPrimPolyToNum(obj,blk);
        end


        for i=1:length(bch_Blocks)
            blk=bch_Blocks{i};
            hConvertStringPolysToNum(blk,'genPoly','descending');
        end


        for i=1:length(rs_Blocks)
            blk=rs_Blocks{i};

            if isR2008aOrEarlier(obj.ver)
                primPoly=get_param(blk,'primPoly');
            else
                primPoly=get_param(blk,'prPoly');
            end
            hConvertStringPolysToNum(blk,'genPoly','descending',primPoly);
        end

    end

    if isR2014bOrEarlier(obj.ver)


        bch_rs_Blocks=[findBCHblocks(obj);findRSblocks(obj)];


        for i=1:length(bch_rs_Blocks)
            blk=bch_rs_Blocks{i};



            convertShorteningSyntax(obj,blk);
        end


        obj.appendRules({...
        '<Block<SourceBlock|"commblkcod2/BCH Encoder"><specShortening:remove><shortenedK:remove>>',...
        '<Block<SourceBlock|"commblkcod2/BCH Decoder"><specShortening:remove><shortenedK:remove>>',...
        '<Block<SourceBlock|"commblkcod2/Integer-Input\nRS Encoder"><specShortening:remove><shortenedK:remove>>',...
        '<Block<SourceBlock|"commblkcod2/Integer-Output\nRS Decoder"><specShortening:remove><shortenedK:remove>>',...
        '<Block<SourceBlock|"commblkcod2/Binary-Input\nRS Encoder"><specShortening:remove><shortenedK:remove>>',...
        '<Block<SourceBlock|"commblkcod2/Binary-Output\nRS Decoder"><specShortening:remove><shortenedK:remove>>',...
        });
    end

end




function bch_Blocks=findBCHblocks(obj)



    bch_Blocks=find_system(obj.modelName,'LookUnderMasks','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'IncludeCommented','on','regexp','on',...
    'MaskType','^BCH Encoder$|^BCH Decoder$');

end

function rs_Blocks=findRSblocks(obj)



    rs_Blocks=find_system(obj.modelName,'LookUnderMasks','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'IncludeCommented','on','regexp','on',...
    'MaskType','^Integer-Input RS Encoder$|^Integer-Output RS Decoder$|^Binary-Input RS Encoder$|^Binary-Output RS Decoder$');

end

function convertPrimPolyToNum(obj,blk)



    currPrimPoly=get_param(blk,'prPoly');


    if length(currPrimPoly)>=2&&currPrimPoly(1)==''''...
        &&currPrimPoly(end)==''''



        currPrimPoly(currPrimPoly=='''')='';

        currPrimPoly=commstr2poly(currPrimPoly,'descending');

        if isR2008aOrEarlier(obj.ver)
            set_param(blk,'primPoly',['[',num2str(currPrimPoly),']']);
        else
            set_param(blk,'prPoly',['[',num2str(currPrimPoly),']']);
        end
    end
end

function convertShorteningSyntax(obj,blk)



    specShort_str=get_param(blk,'specShortening');

    if strcmp(specShort_str,'on')
        n=evalin('base',get_param(blk,'n'));
        k=evalin('base',get_param(blk,'k'));
        shortK=evalin('base',get_param(blk,'shortenedK'));

        if~(isempty(n)||isempty(k)||isempty(shortK))

            m=ceil(log2(n)+1);
            newN=n-k+shortK;
            newM=ceil(log2(newN)+1);
            set_param(blk,'n',num2str(newN));
            set_param(blk,'k',num2str(shortK));

            if(m~=newM)

                set_param(blk,'specPrimPoly','on');

                primPolyStr=sprintf('int2bit(primpoly( %d ,''nodisplay''),%d)''',newM,newM+1);
                if isR2008aOrEarlier(obj.ver)
                    if~isR2006aOrEarlier(obj.ver)
                        set_param(blk,'primPoly',primPolyStr);
                    end
                else
                    set_param(blk,'prPoly',primPolyStr);
                end
            end
        end
    end
end
