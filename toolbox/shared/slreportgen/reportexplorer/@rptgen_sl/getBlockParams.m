function bParam=getBlockParams(blk,~)
















    bParam=get_param(blk,'MaskNames');

    if~isempty(bParam)
        maskVisbility=get_param(blk,'MaskVisibilities');
        bParam=bParam(strcmpi(maskVisbility,'on'));

    else
        blkType=get_param(blk,'blocktype');
        switch blkType
        case 'Scope'
            bParam={};
        case 'SubSystem'

            bParam={};

            if slprivate('is_stateflow_based_block',blk)
                if isa(rptgen_sf.block2chart(blk),'Stateflow.EMChart')
                    bParam={'Script'};
                else
                    if isa(rptgen_sf.block2chart(blk),'Stateflow.TruthTableChart')
                        bParam={'UpdateMethod (TT)','SampleTime (TT)'};
                    else
                        bParam={'Chart'};
                    end
                end
            end
        case 'Inport'
            bParam={
'Port'
'PortDimensions'
'SampleTime'
'DefinedInBlk'
'OutMin'
'OutMax'
'OutDataTypeStr'
            };
        case 'From'
            bParam=locGetDialogParams(blk);
            bParam{end+1}='GotoBlkName';
            bParam{end+1}='GotoBlkLocation';
            bParam{end+1}='DefinedInBlk';
        case 'Outport'




            bParam=locGetDialogParams(blk);
            bParam{end+1}='UsedByBlk';
        case 'Goto'
            bParam=locGetDialogParams(blk);
            bParam{end+1}='FromBlk';
            bParam{end+1}='FromBlkLocation';
            bParam{end+1}='UsedByBlk';

        case 'Lookup_n-D'
            bParam=locGetLookupParams(blk);

        otherwise
            bParam=locGetDialogParams(blk);
        end

    end


    function bParam=locGetDialogParams(blk)

        dParam=get_param(blk,'intrinsicdialogparameters');
        if isstruct(dParam)
            bParam=fieldnames(dParam);
            bParam=bParam(:);
        else
            bParam={};
        end


        function bParams=locGetLookupParams(blk)

            bParams=locGetDialogParams(blk);


            dim=str2double(get_param(blk,'NumberOfTableDimensions'));
            nParams=length(bParams);
            badIdx=false(nParams,1);
            for i=1:nParams
                tokens=regexp(bParams{i},'Dimension(\d+)','tokens');
                if~isempty(tokens)
                    paramDims=str2double(tokens{1}{1});
                    if(paramDims>dim)
                        badIdx(i)=true;
                    end
                end
            end


            bParams(badIdx)=[];


