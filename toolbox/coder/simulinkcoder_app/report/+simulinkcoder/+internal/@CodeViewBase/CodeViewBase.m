classdef(Abstract)CodeViewBase<handle



    events
CodeViewEvent
    end

    properties(Hidden,Access=private)
src
lis
    end

    properties
studio
    end

    properties(Constant)
        cmpName='GLUE2:DDG Component';
    end

    properties(Constant,Abstract)
Tag
    end

    methods(Abstract)
        cv=createSource(obj,studio)
    end

    methods
        function title=getTitle(obj)
            title='Code';
        end
        function pos=getDockPos(obj)
            pos='Right';
        end
        function opt=getDockOpt(obj)
            opt='Tabbed';
        end
    end

    methods(Sealed=true,Static=true)
        ncid=incrementAndGetCid()
    end

    methods
        function obj=CodeViewBase(st)
            obj.studio=st;
        end

        function close(obj)
            cv=obj.src;
            if~isempty(cv)
                cv.ref=cv.ref-1;
                if cv.ref==0
                    st=obj.studio;
                    if isvalid(st)
                        cmp=obj.getComponent();
                        st.hideComponent(cmp);
                        st.destroyComponent(cmp);
                    end
                    delete(cv);
                    obj.src=[];
                end
            end
        end

        function cmp=getComponent(obj)
            st=obj.studio;
            if isvalid(st)
                name=obj.cmpName;
                tag=obj.Tag;
                cmp=st.getComponent(name,tag);
            else
                cmp=[];
            end
        end

        open(obj,buildType,pinned)
        hide(obj)
        showFile(obj,file,line,select)
        callback(obj,src,evt)

        function highlightAnnotation(obj,record)
            if~isempty(obj.src)
                obj.src.highlightAnnotation(record);
            end
        end
        function updateAnnotation(obj,records)
            if~isempty(obj.src)
                obj.src.updateAnnotation(records);
            end
        end
    end
end

