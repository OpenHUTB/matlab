function Signals=checkMixedDataTypes(Signals,modelName)




    idxToRemove=[];



    Inports=find_system(modelName,...
    'SearchDepth',1,'BlockType','Inport');
    Enables=find_system(modelName,...
    'SearchDepth',1,'BlockType','EnablePort');
    Triggers=find_system(modelName,...
    'SearchDepth',1,'BlockType','TriggerPort');
    numPortsInModel=length(Inports)+length(Enables)+length(Triggers);




    useNonContainer=false;


    for kSig=1:length(Signals.Data)




        if Simulink.sdi.internal.Util.isStructureWithTime(Signals.Data{kSig})||...
            Simulink.sdi.internal.Util.isStructureWithoutTime(Signals.Data{kSig})||...
            iofile.Util.isValidTimeExpression(Signals.Data{kSig})||...
            (iofile.Util.isValidSignalDataArray(Signals.Data{kSig})&&~iofile.Util.isFcnCallTableData(Signals.Data{kSig}))













            if Simulink.sdi.internal.Util.isStructureWithTime(Signals.Data{kSig})||...
                Simulink.sdi.internal.Util.isStructureWithoutTime(Signals.Data{kSig})



                numSignals=length(Signals.Data{kSig}.signals);

            elseif iofile.Util.isValidTimeExpression(Signals.Data{kSig})



                numSignals=length(strfind(Signals.Data{kSig},','))+1;

            elseif iofile.Util.isValidSignalDataArray(Signals.Data{kSig})



                dim=size(Signals.Data{kSig});
                numSignals=dim(2)-1;
            end



            if(numSignals~=numPortsInModel&&~iofile.Util.isValidSignalDataArray(Signals.Data{kSig}))||useNonContainer


                idxToRemove=[idxToRemove,kSig];%#ok<AGROW>
            elseif~iofile.Util.isValidSignalDataArray(Signals.Data{kSig})




                if kSig+1~=length(Signals.Data)
                    idxToRemove=[idxToRemove,kSig+1:length(Signals.Data)];%#ok<AGROW>
                    break;
                end
            end
        else

            if kSig==1
                useNonContainer=true;
            end
        end
    end

    if~isempty(idxToRemove)
        Signals.Data(idxToRemove)=[];
        Signals.Names(idxToRemove)=[];
    end
