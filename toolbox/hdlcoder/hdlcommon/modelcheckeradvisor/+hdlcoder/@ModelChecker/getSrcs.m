function candidateBlks=getSrcs(sys,sampleTimeStr)



    candidateBlks={};



    load_system('hdlsllib');


    source_list=find_system('hdlsllib/Sources','MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices);
    source_type=get_param(source_list,'BlockType');
    close_system('hdlsllib');

    blocks=hdlcoder.ModelChecker.find_system_MAWrapper(sys,'RegExp','On','Type','Block');

    src_blocks={};



    for i=1:numel(source_list)

        if~strcmp(source_list{i},'hdlsllib/Sources')
            split=strsplit(source_list{i},'/');
        else
            continue;
        end
        for ii=1:numel(blocks)
            blkType=get_param(blocks{ii},'BlockType');
            if strcmp(source_type{i},blkType)&&~strcmpi(blkType,'subsystem')


                src_blocks{end+1}=blocks{ii};%#ok<AGROW>
            elseif strfind(get_param(blocks{ii},'ReferenceBlock'),split{end})

                src_blocks{end+1}=blocks{ii};%#ok<AGROW>
            else

                continue;
            end
        end
    end
    unique_src_blocks=unique(src_blocks);



    for i=1:numel(unique_src_blocks)

        objParam=get_param(unique_src_blocks{i},'ObjectParameters');

        if isfield(objParam,'SampleTime')
            [sample_time,~]=slResolve(get_param(unique_src_blocks{i},'SampleTime'),unique_src_blocks{i});
            if strcmpi(num2str(sample_time),sampleTimeStr)
                candidateBlks{end+1}=unique_src_blocks{i};%#ok<AGROW>
            end
        elseif isfield(objParam,'tsamp')
            [sample_time,~]=slResolve(get_param(unique_src_blocks{i},'tsamp'),unique_src_blocks{i});
            if strcmpi(num2str(sample_time),sampleTimeStr)
                candidateBlks{end+1}=unique_src_blocks{i};%#ok<AGROW>
            end
        elseif isfield(objParam,'CountSampTime')
            [sample_time,~]=slResolve(get_param(unique_src_blocks{i},'CountSampTime'),unique_src_blocks{i});
            if strcmpi(num2str(sample_time),sampleTimeStr)
                candidateBlks{end+1}=unique_src_blocks{i};%#ok<AGROW>
            end
        elseif strcmpi(sampleTimeStr,'inf')&&...
            strcmpi(get_param(unique_src_blocks{i},'BlockType'),'ground')&&...
            ~Stateflow.SLUtils.isChildOfStateflowBlock(unique_src_blocks{i})

            candidateBlks{end+1}=unique_src_blocks{i};%#ok<AGROW>
        else
            continue;
        end
    end
end
