function MaskParamsToSources(this)






    portRows=l_PortMaskParamsToRows(this);
    this.PortTableSource=hdllinkddg.PortTableSource('PortTable',portRows);

    clockRows=l_ClockMaskParamsToRows(this);
    this.ClockTableSource=hdllinkddg.ClockTableSource('ClockTable',clockRows);

    this.CommSource=hdllinkddg.CommSource('HdlComm',{...
    this.Block.CommLocal,this.Block.CommHostName,...
    this.Block.CommSharedMemory,this.Block.CommPortNumber,...
    this.Block.CommShowInfo,this.Block.CosimBypass});

end




function portRows=l_PortMaskParamsToRows(this)

    UNUSED_VAR_STR='{''UNUSED_VAR''}';

    if strcmp(this.block.idxCellArray,UNUSED_VAR_STR)
        PortPaths=this.Block.PortPaths;
        PortModes=this.Block.PortModes;
        PortTimes=this.Block.PortTimes;
        PortTypeEnum=this.Block.PortSigns;
        PortFracLengths=this.Block.PortFracLengths;

        this.idxCellArray=this.Block.idxCellArray;

        numRows=length(eval(PortModes));

        [PortTimes,PortFracLengths]=...
        l_CheckR14PortCompatibility(this,numRows,PortTimes,PortFracLengths);

    else
        [PortPaths,PortModes,PortTimes,PortTypeEnum,PortFracLengths]=...
        l_LegacyPortMaskParamTranslation(this);
    end







    PortPaths=strread(PortPaths,'%s','delimiter',';','whitespace','');
    PortModes=num2cell(eval(PortModes))';

    PortTimes=strread(PortTimes(2:end-1),'%s','delimiter',',','whitespace','');

    PortTypeEnum=num2cell(eval(PortTypeEnum))';
    PortFracs=strread(PortFracLengths(2:end-1),'%s','delimiter',',','whitespace','');

    [PortDataTypes,PortSigns]=l_PortDataTypeCoversion(PortTypeEnum);

    portRows=[PortPaths,PortModes,PortTimes,PortDataTypes,PortSigns,PortFracs];

end

function[PortDataTypes,PortSigns]=l_PortDataTypeCoversion(PortTypeEnum)
    nrow=numel(PortTypeEnum);

    PortDataTypes=cell(nrow,1);
    PortSigns=cell(nrow,1);

    for m=1:nrow
        switch PortTypeEnum{m}
        case-1
            PortDataTypes{m}=-1;
            PortSigns{m}=1;
        case 0
            PortDataTypes{m}=0;
            PortSigns{m}=0;
        case 1
            PortDataTypes{m}=0;
            PortSigns{m}=1;
        case 2
            PortDataTypes{m}=1;
            PortSigns{m}=1;
        case 3
            PortDataTypes{m}=2;
            PortSigns{m}=1;
        case 4
            PortDataTypes{m}=3;
            PortSigns{m}=1;
        otherwise
            error('HDLVerifier:internal:badPortEnumType','(hdlv internal) bad PortTypeEnum value');
        end
    end


end


function[PortPaths,PortModes,PortTimes,PortSigns,PortFracLengths]=l_LegacyPortMaskParamTranslation(this)





    this.idxCellArray=UNUSED_VAR_STR;


    outTs=this.Block.PortTimes;
    otherPortTs='1';

    try
        ca=eval(this.Block.idxCellArray);
    catch
        ca={''};
    end

    PortPaths='';
    PortModes='[';
    PortTimes='[';
    PortSigns='[';
    PortFracLengths='[';

    for ii=1:2:length(ca)
        switch ca{ii+1}
        case 'in'
            PortPaths=[PortPaths,';',ca{ii}];
            PortModes=[PortModes,' 1'];
            PortTimes=[PortTimes,',',otherPortTs];
        case 'out'
            PortPaths=[PortPaths,';',ca{ii}];
            PortModes=[PortModes,' 2'];
            PortTimes=[PortTimes,',',outTs];
        end
        PortSigns=[PortSigns,' -1'];
        PortFracLengths=[PortFracLengths,',0'];
    end

    PortModes=[PortModes,']'];
    PortTimes=[PortTimes,']'];
    PortSigns=[PortSigns,']'];
    PortFracLengths=[PortFracLengths,']'];
    if isempty(PortPaths)
        PortPaths=' ';
    else

        PortPaths=PortPaths(2:end);
        PortTimes=PortTimes([1,3:end]);
        PortFracLengths=PortFracLengths([1,3:end]);
    end
end


function[ptStr,pfStr]=l_CheckR14PortCompatibility(this,numRows,PortTimes,PortFracLengths)








    inds=strfind(PortTimes,',');

    if length(inds)~=numRows-1

        try
            pt=strread(PortTimes(2:end-1),'%s');
            pt2=sprintf('%s,',pt{:});
            ptStr=['[',pt2];
            ptStr(end)=']';
        catch

            ptStr='[';
            for ii=1:numRows
                ptStr=[ptStr,',1'];
            end
            ptStr=[ptStr,']'];

            ptStr=ptStr([1,3:end]);
        end
    else
        ptStr=PortTimes;
    end



    inds=strfind(PortFracLengths,',');

    if length(inds)~=numRows-1

        try
            pf=strread(PortFracLengths(2:end-1),'%s');
            pf2=sprintf('%s,',pt{:});
            pfStr=['[',pt2];
            pfStr(end)=']';
        catch

            pfStr='[';
            for ii=1:numRows
                pfStr=[pfStr,',0'];
            end
            pfStr=[pfStr,']'];

            pfStr=pfStr([1,3:end]);
        end
    else
        pfStr=PortFracLengths;
    end

end




function clockRows=l_ClockMaskParamsToRows(this)

    UNUSED_VAR_STR='{''UNUSED_VAR''}';

    [ClockPaths,ClockModes,ClockTimes]=deal('');

    if strcmp(this.block.idxCellArray,UNUSED_VAR_STR)
        ClockPaths=this.Block.ClockPaths;
        ClockModes=this.Block.ClockModes;
        ClockTimes=this.Block.ClockTimes;

        this.idxCellArray=this.Block.idxCellArray;

        numRows=length(eval(ClockModes));

        ClockTimes=l_CheckR14ClockCompatibility(this,numRows,ClockTimes);

    else
        [ClockPaths,ClockModes,ClockTimes]=l_LegacyClockMaskParamTranslation(this);
    end







    ClockPaths=strread(ClockPaths,'%s','delimiter',';','whitespace','');
    ClockModes=num2cell(eval(ClockModes))';
    ClockTimes=strread(ClockTimes(2:end-1),'%s','delimiter',',','whitespace','');

    if(isempty(ClockModes))
        clockRows=cell(0,3);
    else
        clockRows=[ClockPaths,ClockModes,ClockTimes];
    end

end


function[ClockPaths,ClockModes,ClockTimes]=l_LegacyClockMaskParamTranslation(this)

    UNUSED_VAR_STR='{''UNUSED_VAR''}';



    this.idxCellArray=UNUSED_VAR_STR;

    otherClockTs='2';
    try
        ca=eval(this.Block.idxCellArray);
    catch
        ca={''};
    end

    ClockPaths='';
    ClockModes='[';
    ClockTimes='[';

    for ii=1:2:length(ca)
        switch ca{ii+1}
        case 'fclk'
            ClockPaths=[ClockPaths,';',ca{ii}];
            ClockModes=[ClockModes,' 1'];
            ClockTimes=[ClockTimes,',',otherClockTs];
        case 'rclk'
            ClockPaths=[ClockPaths,';',ca{ii}];
            ClockModes=[ClockModes,' 2'];
            ClockTimes=[ClockTimes,',',otherClockTs];
        end
    end

    ClockModes=[ClockModes,']'];
    ClockTimes=[ClockTimes,']'];
    if isempty(ClockPaths)
        ClockPaths=' ';
    else

        ClockPaths=ClockPaths(2:end);
        ClockTimes=ClockTimes([1,3:end]);
    end

end


function ctStr=l_CheckR14ClockCompatibility(this,numRows,ClockTimes)







    inds=strfind(ClockTimes,',');

    if length(inds)~=numRows-1

        try
            ct=strread(ClockTimes(2:end-1),'%s');
            ct2=sprintf('%s,',ct{:});
            ctStr=['[',ct2];
            ctStr(end)=']';
        catch

            ctStr='[';
            for ii=1:numRows
                ctStr=[ctStr,',1'];
            end
            ctStr=[ctStr,']'];
            if(numRows>1)
                ctStr=ctStr([1,3:end]);
            end
        end
    elseif numRows==1
        ctStr=strrep(ClockTimes,' ]',']');
    else
        ctStr=ClockTimes;
    end

end


