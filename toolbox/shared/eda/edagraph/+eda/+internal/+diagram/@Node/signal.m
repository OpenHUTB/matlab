function signalHandle=signal(this,varargin)





    arg=this.componentArg(varargin);

    argFields=fields(arg);

    argCell='';

    for i=1:length(argFields)
        argCell{end+1}=argFields{i};%#ok<AGROW>
        argCell{end+1}=arg.(argFields{i});%#ok<AGROW>
    end


    signalHandle=eda.internal.component.Signal(argCell{:});

    this.ChildEdge{end+1}=signalHandle;

end

