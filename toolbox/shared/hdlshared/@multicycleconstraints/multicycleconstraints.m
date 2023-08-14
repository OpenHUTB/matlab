



classdef multicycleconstraints<handle


    properties
        tcinfo;
        tool;
        mcpinfo;
        dutname;
        filename;
        filepath;
        skip;
    end

    methods

        function obj=multicycleconstraints(hc)




            obj.skip=false;


            tcinfoMap=get(hc,'TimingControllerInfo');


            if hc.getParameter('clockinputs')>1
                obj.skip=true;
                warning(message('HDLShared:hdlshared:mcpNoMultipleClocks'));
                return;
            end


            if isempty(tcinfoMap)||tcinfoMap.Count<2
                obj.skip=true;
                warning(message('HDLShared:hdlshared:mcpMustBeMultiRate'));
                return;
            end


            obj.tcinfo=hc.getTimingControllerInfo(1);
            obj.mcpinfo=struct.empty;
            obj.tool=hc.getParameter('SynthesisTool');
            obj.dutname=hdlentitytop;


            switch(lower(obj.tool))
            case 'xilinx vivado'
                ext='.xdc';
            case 'xilinx ise'
                ext='.ucf';
            case{'altera quartus ii','intel quartus pro'}
                ext='.sdc';
            case ''
                obj.skip=true;
                warning(message('HDLShared:hdlshared:mcpToolNotSet'));
                return;
            otherwise
                obj.skip=true;
                warning(message('HDLShared:hdlshared:mcpToolNotSupported',obj.tool));
                return;
            end


            if~obj.skip

                if hc.getParameter('gen_eda_scripts')&&~strcmp(hc.getParameter('hdlsynthtool'),'None')
                    warning(message('HDLShared:hdlshared:mcpEDAScriptUnsupported'));
                end
            end




            obj.filename=[hdlentitytop,'_constraints',ext];
            obj.filepath=fullfile(hdlGetCodegendir,obj.filename);
            hc.cgInfo.hdlFiles{end+1}=obj.filename;
        end

    end

    methods(Access=private)

        writeVivadoTcl(obj);
        writeQuartusTcl(obj);
    end

    methods


        function build(obj)


            if obj.skip
                return;
            end

            dtinfo=obj.tcinfo.dutTimingInfo;






            gp=pir;
            tcNws=gp.getTopPirCtx.findTimingControllerNetworks;

            if isempty(tcNws)
                error('Could not find timing controller component to derive instance name from.');
            end

            if numel(tcNws)>1
                error(message('HDLShared:hdlconnectivity:multipletimingcontrollers'));
            end

            if gp.isPIRTCCtxBased
                tcRefComp=gp.getTopPirCtx.findTimingControllerRefComp;
            else
                tcRefComp=tcNws.instances;
            end

            tcName=tcRefComp.Name;



            for i=1:length(obj.tcinfo.enablemap)
                if~isa(obj.tcinfo.enablemap(i),'hdlcoder.signal')
                    continue;
                end
                attrValue=obj.tcinfo.enablemap(i).getAttribute('mcp_info');
                if~isempty(attrValue)


                    if strcmpi(obj.tool,'xilinx vivado')
                        addConstraints=true;
                    elseif dtinfo.offset(i)==0
                        addConstraints=true;
                    else
                        addConstraints=false;
                    end

                    if addConstraints

                        obj.mcpinfo(end+1).attrValue=attrValue;
                        obj.mcpinfo(end).setupMultiplier=dtinfo.down(i)/dtinfo.up(i);
                        obj.mcpinfo(end).holdMultiplier=dtinfo.down(i)/dtinfo.up(i)-1;
                        obj.mcpinfo(end).tcName=tcName;
                        obj.mcpinfo(end).regName=obj.tcinfo.enablemap(i).Name;
                        obj.mcpinfo(end).offset=dtinfo.offset(i);
                    end
                end
            end


        end

        function write(obj)


            if obj.skip
                return;
            end

            switch(lower(obj.tool))
            case 'xilinx vivado'
                writeVivadoXdc(obj);
            case 'xilinx ise'
                writeIseUcf(obj);
            case{'altera quartus ii','intel quartus pro'}
                writeQuartusSdc(obj);
            end
        end


    end

    methods(Static=true)



    end
end



