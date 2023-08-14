function outDataTypeStr=getUDTStrFromFixPtInfo(h,blkObj,signValStr,wlValueStr,varargin)%#ok




    if ischar(signValStr)


        if strcmpi(signValStr,'Unsigned')
            sgVal=0;
        elseif strcmpi(signValStr,'Signed')
            sgVal=1;
        else
            sgVal=[];
        end
    else


        sgVal=double(signValStr);
    end


    blkPath=regexprep(blkObj.getFullName,'\n',' ');
    [isWLValid,wlVal]=evalBlkWLFLVal(blkPath,wlValueStr);

    if nargin>4

        [isFLValid,flVal]=evalBlkWLFLVal(blkPath,varargin{1});

        if isWLValid&&isFLValid

            if~isempty(sgVal)
                outDataTypeStr=sprintf('fixdt(%d,%d,%d)',sgVal,wlVal,flVal);
            else

                outDataTypeStr=sprintf('fixdt([],%d,%d)',wlVal,flVal);
            end
        else
            outDataTypeStr='';

        end
    else

        if isWLValid

            if~isempty(sgVal)
                outDataTypeStr=sprintf('fixdt(%d,%d)',sgVal,wlVal);
            else

                outDataTypeStr=sprintf('fixdt([],%d)',wlVal);
            end
        else
            outDataTypeStr='';

        end
    end


    function[isValid,val]=evalBlkWLFLVal(blockPath,unevaledParamStr)

        try
            val=slResolve(unevaledParamStr,blockPath);
            isValid=~isempty(val);
        catch
            val=[];
            isValid=false;
        end





