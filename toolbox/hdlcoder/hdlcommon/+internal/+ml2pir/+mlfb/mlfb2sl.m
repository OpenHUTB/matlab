function[success,messages]=mlfb2sl(...
    functionBlockPath,inPlaceConversion,updateDiagram,simgenCfg)





    if nargin<2
        inPlaceConversion=true;
    end

    if nargin<3
        updateDiagram=false;
    end

    if nargin<4
        simgenCfg=internal.ml2pir.SimGenConfig;

        sat=internal.ml2pir.mlfb.getIntegersSaturateOnOverflow(functionBlockPath);
        simgenCfg.SaturateOnIntegerOverflow=sat;
    end

    messages=internal.mtree.Message.empty;

    try

        if updateDiagram
            sys=get_param(functionBlockPath,'Parent');
            sysHandle=get_param(sys,'Handle');
            SLM3I.SLDomain.updateDiagram(sysHandle);
        end

        report=internal.ml2pir.mlfb.fetchReport(functionBlockPath);


        modelName='';
        [mdlName,subsysPath,messages,success]=...
        internal.ml2pir.matlab2simulink(report,modelName,simgenCfg);

        if inPlaceConversion&&success

            draw_subsystem(functionBlockPath,subsysPath)


            bdclose(mdlName);
            delete([mdlName,'.slx']);
        end

    catch ex %#ok<NASGU> % useful for debugging
        success=false;
    end

end

function draw_subsystem(functionBlockPath,newBlockPath)
    blockDestMdl=get_param(functionBlockPath,'Parent');


    pos=get_param(functionBlockPath,'position');

    mlfbName=get_param(functionBlockPath,'Name');


    set_signal_names(functionBlockPath);


    delete_block(functionBlockPath);


    add_block(newBlockPath,[blockDestMdl,'/',mlfbName,'_mdl'],'position',pos);

end

function set_signal_names(functionBlockPath)







    portHandles=get_param(functionBlockPath,'PortHandles');
    outputHandles=portHandles.Outport;
    outputSignalNames=get_param(functionBlockPath,'OutputSignalNames');


    for idx=1:numel(outputHandles)
        lineH=get_param(outputHandles(idx),'Line');


        if isempty(get_param(lineH,'Name'))
            dstPorts=get_param(lineH,'DstPortHandle');
            for ydx=1:numel(dstPorts)
                dstBlock=get_param(dstPorts(ydx),'Parent');
                dstBlockType=get_param(dstBlock,'BlockType');

                if strcmp(dstBlockType,'BusCreator')

                    set_param(lineH,'Name',outputSignalNames{idx});
                end
            end
        end
    end
end


