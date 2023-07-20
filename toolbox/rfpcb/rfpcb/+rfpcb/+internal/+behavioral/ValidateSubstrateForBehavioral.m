function ValidateSubstrateForBehavioral(obj)






    if numel(unique(obj.Substrate.EpsilonR))>1||...
        numel(unique(obj.Substrate.LossTangent))>1
        error(message('rfpcb:rfpcberrors:Unsupported',...
        'Heterogenous substrate',...
        ['behavioral modeling of ',class(obj)]))
    end


    if unique(obj.Substrate.EpsilonR)==1
        Er=obj.Substrate.EpsilonR(1);
        if Er==1
            error(message('rfpcb:rfpcberrors:InvalidValueGreater',...
            'EpsilonR',num2str(Er)));
        end
    end
end