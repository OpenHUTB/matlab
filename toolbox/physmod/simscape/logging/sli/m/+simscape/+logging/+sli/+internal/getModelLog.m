function[log,logName]=getModelLog(mdl)





    log=[];
    logName='';


    if~isempty(mdl)
        cs=getActiveConfigSet(mdl);
        if(cs.hasProp('SimscapeLogName'))
            logName=cs.get_param('SimscapeLogName');
            logType='simscape.logging.Node';

            if~strcmp(get_param(mdl,'ReturnWorkspaceOutputs'),'on')

                log=lFromBase(logName,logType);
            else



                soName=get_param(mdl,'ReturnWorkspaceOutputsName');
                soType='Simulink.SimulationOutput';
                res=lFromBase(soName,soType);
                if~isempty(res)
                    log=res.find(logName);
                end
            end
        end
    end
end

function maybeObj=lFromBase(name,type)


    maybeObj=[];
    fcn=['whos(''',name,''')'];
    res=evalin('base',fcn);
    if numel(res)==1&&strcmp(res.class,type)
        maybeObj=evalin('base',name);
    end
end
