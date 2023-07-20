function pvpairs=parseParams(this,params)




    pvpairs=struct();
    assert(mod(length(params),2)==0);

    validParams={'batchsize','targetdir','targetfile','targetarch',...
    'cudnnversion','opencv','codetarget','targetmain',...
    'codegenonly','computecapability','exponentdata','verbose',...
    'hastrueoutputlayer','hastrueinputlayer','leglevel',...
    'activationlayer','maxpooltype','hasunpool'...
    ,'unpoolremainder','hastransposedconv','processorconfig','validatetrimmablekernel','processordatatype'};

    for i=1:2:length(params)
        param=lower(params{i});
        if(~contains(validParams,param))


            error(message('gpucoder:cnncodegen:invalid_parameter'));
        end
        value=params{i+1};

        pvpairs.(param)=value;
    end
end

