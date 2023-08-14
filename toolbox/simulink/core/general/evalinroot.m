function outputValue=evalinroot(h,inputString,inputStringType)





















    ddConn=h.nodeconnection;

    if(h.hasdictionaryconnection)


        oc=[];%#ok
        if(slfeature('SLDataDictionaryDuplicateMode')>0)&&...
            (slfeature('SLDataDictionarySingleTopModelInClosure')>0)&&...
            isequal(ddConn.Client,'BusEditor')
            Simulink.dd.private.setSingleTopModelInClosure(ddConn.DataSource,true);
            oc=onCleanup(@()Simulink.dd.private.setSingleTopModelInClosure(ddConn.DataSource,false));
        end

        if(nargin==3&&inputStringType==1)
            outputValue=[];
            if strcmp(h.defaultbasetype,'Simulink.Bus')
                outputValue=ddConn.DataSource.getEntriesWithClass('Global','Simulink.Bus');
                outputValue=sort(outputValue);
            end
            if strcmp(h.additionalbasetype,'Simulink.ConnectionBus')
                outputVal=ddConn.DataSource.getEntriesWithClass('Global','Simulink.ConnectionBus');
                outputVal=sort(outputVal);
                if isempty(outputValue)
                    outputValue=outputVal;
                else
                    outputValue=vertcat(outputValue,outputVal);
                end
            end

        elseif(nargin==3&&inputStringType==2)
            try
                outputValue=ddConn.DataSource.getEntryCached(['Global.',inputString]);
            catch ME
                if strcmp(ME.identifier,'SLDD:sldd:EntryNotFound')
                    slddfile=ddConn.DataSource.filespec;
                    dd=Simulink.data.dictionary.open(slddfile);
                    if(dd.HasAccessToBaseWorkspace)
                        outputValue=evalin('base',inputString);
                    end
                else
                    rethrow(ME);
                end
            end
        elseif nargout==0
            ddConn.evalin(inputString);
        else
            outputValue=ddConn.evalin(inputString);
        end
    else
        if(nargout==0)

            ddConn.evalin(inputString);
        elseif(nargout==1)
            outputValue=ddConn.evalin(inputString);
        end
    end
