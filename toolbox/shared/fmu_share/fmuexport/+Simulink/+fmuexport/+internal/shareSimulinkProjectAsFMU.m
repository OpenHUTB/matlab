function shareSimulinkProjectAsFMU(model,project,varargin)
    narginchk(2,14);



    modelData=struct('Model',model,'Project',project,...
    'Description','','Author','','Copyright','','License','',...
    'fmu','','icon','','target','slproject');
    [~,fmu,~]=fileparts(model);
    modelData.fmu=fullfile(pwd,[fmu,'.fmu']);


    for i=1:2:length(varargin)
        if i+1>length(varargin)
            throwAsCaller(MSLException([],message('FMUShare:FMU:UnpairedArguments',varargin{i})));
        end

        switch varargin{i}
        case '-description'
            modelData.Description=varargin{i+1};
        case '-author'
            modelData.Author=varargin{i+1};
        case '-copyright'
            modelData.Copyright=varargin{i+1};
        case '-license'
            modelData.License=varargin{i+1};
        case '-fmuname'
            modelData.fmu=varargin{i+1};
        case '-fmuicon'
            modelData.icon=varargin{i+1};
        otherwise
            throwAsCaller(MSLException([],message('FMUShare:FMU:UnrecognizedArguments',varargin{i})));
        end
    end
    Simulink.fmuexport.internal.packToolCouplingFMU(modelData);
end
