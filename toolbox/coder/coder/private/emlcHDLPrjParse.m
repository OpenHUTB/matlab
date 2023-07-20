function fcnName=emlcHDLPrjParse(prj,hdlCfg)






    if nargin<2
        hdlCfg=coder.config('hdl');
    end

    if ischar(prj)
        prj=xmlread(prj);
    end

    doc=prj.getFirstChild();
    processNode(doc,hdlCfg);

    entryPoints=prj.getElementsByTagName('fileset.entrypoints');
    entryPoints=entryPoints.item(0).getElementsByTagName('file');
    if entryPoints.getLength==0
        fcnName='';
        ccdiagnosticid('Coder:buildProcess:invalidEntryPointFile');
        return;
    else
        fcnName=char(entryPoints.item(0).getAttribute('value'));
    end

    sf=doc.getElementsByTagName('fileset.scriptfile');
    sfc=sf.item(0);
    if isempty(sfc)



        scriptName='';
    else
        scriptName=sfc.getTextContent();
        scriptName=char(scriptName);
    end

    fcnName=strrep(fcnName,['${PROJECT_ROOT}',filesep],'');
    fcnName=strtrim(fcnName);
    scriptName=strrep(scriptName,['${PROJECT_ROOT}',filesep],'');

    [~,fcnName,~]=fileparts(fcnName);
    [~,scriptName,~]=fileparts(scriptName);

    hdlCfg.DesignFunctionName=fcnName;
    hdlCfg.TestBenchScriptName=strtrim(scriptName);

end


function processNode(node,hdlCfg)
    persistent var_HDLCodingStandard_length;

    if(isempty(var_HDLCodingStandard_length))
        var_HDLCodingStandard_length=length('var.HDLCodingStandard');
    end

    tag=node.getNodeName();
    tag=char(tag);


    if strcmp(tag,'unset')
        return;
    end

    param=[];

    if isempty(param)&&strncmp(tag,'param.hdl.',10)
        param=tag(11:end);
        value=node.getTextContent();
        value=char(value);


        try
            class(hdlCfg.(param));
            isField=true;
        catch %#ok<CTCH>
            isField=false;
        end

        if isField
            try
                switch(class(hdlCfg.(param)))
                case 'char'



                    if strcmpi(param,'ScalarizePorts')
                        switch value
                        case 'true'
                            value='on';
                        case 'false'
                            value='off';
                        end
                    end
                    if strcmpi(param,'BitstreamBuildMode')
                        if strcmpi(value,'true')
                            value='External';
                        else
                            value='Internal';
                        end
                    elseif strncmp(value,'option.hdl.',11)
                        value=value(12:end);
                        if strcmpi(param,'ExecutionMode')
                            switch value
                            case 'FreeRunning'
                                value='Free running';
                            case 'CoprocessingBlocking'
                                value='Coprocessing - blocking';
                            otherwise
                                value=hdlCfg.(param);
                            end
                        elseif strcmpi(param,'EnumEncodingScheme')
                            switch value
                            case 'EnumEncDefault'
                                value='default';
                            case 'EnumEncOnehot'
                                value='onehot';
                            case 'EnumEncTwohot'
                                value='twohot';
                            case 'EnumEncBinary'
                                value='binary';
                            otherwise
                                value=hdlCfg.(param);
                            end
                        elseif strcmpi(param,'SystemCTestBenchStimulus')
                            switch value
                            case 'HDLTB'
                                value='HDL Test bench stimulus';
                            case 'RAND_TB'
                                value='Test bench with random input stimulus';
                            otherwise
                                value=hdlCfg.(param);
                            end
                        end
                    elseif strncmp(value,'option.workflow.',16)
                        value=value(17:end);
                        switch value
                        case 'GenericAsicFpga'
                            value='Generic ASIC/FPGA';
                        case 'IpCore'
                            value='IP Core Generation';
                        case 'FpgaTurnkey'
                            value='FPGA Turnkey';
                        case 'HLS'
                            value='High Level Synthesis';
                        otherwise
                            value=hdlCfg.(param);
                        end
                    end
                    hdlCfg.(param)=value;
                case 'logical'
                    if~isempty(value)
                        if strcmpi(value,'true')
                            hdlCfg.(param)=true;
                        elseif strcmpi(value,'false')
                            hdlCfg.(param)=false;
                        else
                            disp(['Cannot handle ''',param,''' with value ''',value,'''']);
                        end
                    end
                case 'double'
                    if~isempty(value)
                        hdlCfg.(param)=str2double(value);
                    end
                case{'int8','int16','int32','int64','uint8','uint16','uint32','uint64'}
                    if~isempty(value)
                        hdlCfg.(param)=str2num(value);%#ok<ST2NM>
                    end
                otherwise
                    disp(['Cannot handle ''',param,''' with value ''',value,'''']);
                end
            catch ex
                disp(['Error setting ''',param,''' to ''',value,'''. ',ex.message]);
            end
        else

            switch(param)
            case{'CodeGenDir',...
                'CodeGenTarget',...
                'WorkingDirectory',...
                'WorkingSpecifiedDirectory',...
                'BuildDirectory',...
                'BuildSpecifiedDirectory',...
                'SearchPath',...
                'InputFrequency',...
                'TargetInterface',...
                'EmbeddedSystemProjectFolder',...
'CodegenWorkflow'
                }

            case{'build_btn'}

            otherwise
                disp(['''Illegal field ''',param,''' with value ''',value,'''']);
            end
        end
    elseif(isempty(param)&&strncmp(tag,'var.HDLCodingStandard',var_HDLCodingStandard_length))
        if(isprop(hdlCfg.HDLCodingStandardCustomizations,'ShowPassingRules'))

            offset=var_HDLCodingStandard_length+2;
            param=tag(offset:end);
            value=node.getTextContent();
            value=char(value);

            subparams=strsplit(param,'_');
            assert(length(subparams)==2,['fieldname_subfieldname ordering not found for ',param]);



            if(strcmpi(subparams{1},'FilterPassingRules'))
                subparams{1}='ShowPassingRules';
                if strcmpi(value,'true')
                    value='false';
                else
                    value='true';
                end
            end

            try
                switch(subparams{2})
                case 'enable'
                    hdlCfg.HDLCodingStandardCustomizations.(subparams{1}).enable=strcmpi(value,'true');
                case{'length','width','depth'}

                    hdlCfg.HDLCodingStandardCustomizations.(subparams{1}).(subparams{2})=str2double(value);
                case{'min','max'}

                    orig_L=hdlCfg.HDLCodingStandardCustomizations.(subparams{1}).length;
                    switch(subparams{2})
                    case 'min'
                        update_L=[str2double(value),orig_L(2)];
                    case 'max'
                        update_L=[orig_L(1),str2double(value)];
                    end
                    if(update_L(1)>=update_L(2))
                        warning(message('hdlcommon:IndustryStandard:InvalidMinMax',subparams{1},subparams{2}));
                    else
                        hdlCfg.HDLCodingStandardCustomizations.(subparams{1}).length=update_L;
                    end
                end
            catch mEx
                warning(mEx);
            end
        end
    end


    childItr=node.getFirstChild();
    while~isempty(childItr)
        processNode(childItr,hdlCfg);
        childItr=childItr.getNextSibling();
    end

end
