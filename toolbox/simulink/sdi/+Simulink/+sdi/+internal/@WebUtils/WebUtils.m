


classdef WebUtils



    methods(Hidden,Static)


        function ret=featureOn(bStartControllers)






            eng=Simulink.sdi.Instance.engine;%#ok<NASGU>


            ret.SDITreeTableTestingHook=slsvTestingHook('SDITreeTableTestingHook',1);


            Simulink.sdi.clear();



            if nargin>0&&bStartControllers
                apiObj=Simulink.sdi.internal.ConnectorAPI.getAPI();
                start(apiObj);
            end
        end


        function ret=featureRestore(fvals)

            Simulink.sdi.close();
            pause(1);
            Simulink.sdi.WebClient.disconnectAllClients();


            apiObj=Simulink.sdi.internal.ConnectorAPI.getAPI();
            stop(apiObj);


            Simulink.sdi.Instance.getSetGUI([]);


            eng=Simulink.sdi.Instance.engine;
            Simulink.sdi.clear();
            eng.dirty=false;


            Simulink.sdi.internal.WebInterface.setGetResetEngine('reset');


            if nargin<1
                fvals.SDITreeTableTestingHook=0;
            end
            ret=struct();
            features=fieldnames(fvals);
            for idx=1:length(features)
                fname=features{idx};
                fval=fvals.(fname);
                if isempty(strfind(fname,'TestingHook'))
                    ret.(fname)=slfeature(fname,fval);
                else
                    ret.(fname)=slsvTestingHook(fname,fval);
                end
            end
        end


        function sigIDs=getInstrumentedSignalIDs(mdl)
            sigs=get_param(mdl,'InstrumentedSignals');
            if isempty(sigs)
                sigIDs={};
                return
            end
            numSigs=sigs.Count;
            sigIDs=cell(numSigs,1);
            for idx=1:numSigs
                sig=get(sigs,idx);
                sigIDs{idx}=sig.UUID;
            end
        end
    end


    properties(Hidden,Constant)
        SDI_REL_URL='toolbox/shared/sdi/web/MainView/sdi.html';
    end

end


