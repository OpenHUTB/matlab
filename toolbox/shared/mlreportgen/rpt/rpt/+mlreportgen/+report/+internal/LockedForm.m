classdef LockedForm<handle




    methods

        function form=LockedForm(needsSlLicense)
            if nargin>0
                form.NeedsSlRptgenLicense=needsSlLicense;
            else
                form.NeedsSlRptgenLicense=false;
            end
        end

    end

    methods(Static)

        function add(formImpl,report,content)
            if~isempty(content)
                if~ismatrix(content)
                    error(message(...
                    "mlreportgen:report:error:unsupportedDimensions"));
                end
                if iscell(content)
                    len=length(content);
                    for i=1:len
                        mlreportgen.report.internal.LockedForm.add(...
                        formImpl,report,content{i});
                    end
                elseif isa(content,'table')
                    append(formImpl,content);
                else
                    if ischar(content)
                        append(formImpl,content);
                    else
                        nel=numel(content);
                        if nel>1
                            for i=1:nel
                                item=content(i);
                                mlreportgen.report.internal.LockedForm.add(...
                                formImpl,report,item);
                            end
                        else
                            if isa(content,'mlreportgen.report.ReporterBase')
                                child=getImpl(content,report);
                                mlreportgen.report.internal.LockedForm.add(...
                                formImpl,report,child);
                            elseif isa(content,'mlreportgen.finder.Result')
                                reporter=getReporter(content);
                                if~isempty(reporter)
                                    child=getImpl(reporter,report);
                                    mlreportgen.report.internal.LockedForm.add(...
                                    formImpl,report,child);
                                end
                            else
                                if~isempty(content)
                                    if isa(content,'mlreportgen.dom.Element')&&...
                                        ~isempty(content.Parent)
                                        append(formImpl,clone(content));
                                    else
                                        append(formImpl,content);
                                    end















                                    plo=getContext(report,'ReporterLayout');
                                    if~isempty(plo)&&...
                                        formImpl==plo.Form&&...
                                        ~isempty(formImpl.CurrentPageLayout)
                                        plo.Layout=formImpl.CurrentPageLayout;
                                        setContext(report,'ReporterLayout',plo);
                                    end
                                end
                            end
                        end
                    end

                end
            end
        end
    end

    methods(Sealed,Access=protected)
        function[key,owner,license]=getOpenArgs(obj,varargin)
            key='';
            owner='';
            license=obj.NeedsSlRptgenLicense;
            if nargin>1
                key=varargin{1};
            end

            if nargin>2
                owner=varargin{2};
            end

        end
    end


    properties(Access=private,Hidden)
        NeedsSlRptgenLicense=false;
    end

end
