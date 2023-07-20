function insertRequirementInfoForComp(this,varargin)





    if nargin==2
        hC=varargin{1};
        shandle=hC.SimulinkHandle;
    elseif nargin==3
        hC=varargin{1};
        shandle=varargin{2};
    end

    if shandle>=0
        req=rmi.getReqs(shandle);
        obj=get_param(shandle,'Object');
        if~isempty(req)&&~isa(obj,'Simulink.Annotation')
            if this.DUTMdlRefHandle>0

                if this.isDutModelRef
                    origFullPath=obj.getFullName;
                else
                    origFullPath=regexprep(obj.getFullName,this.ModelName,...
                    this.OrigStartNodeName,'once');
                end
                shandle=get_param(origFullPath,'handle');
            end

            sName=coder.internal.getNameForBlock(shandle);
            try
                reqstring=rmi('codecomment',shandle);
            catch me %#ok<NASGU>
                reqstring=[];
            end
            if~isempty(reqstring)

                formattedReq=strrep(reqstring(2:end),[newline,'*'],newline);
                formattedReq=['Block requirements for ',sName,hdl.newline,...
                formattedReq];
                hC.addComment(formattedReq);
            end
        end
    end

end

