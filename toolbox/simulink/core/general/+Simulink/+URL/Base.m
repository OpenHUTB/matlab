




classdef Base
    properties(Access=protected)
Parent
ObjKind
ObjId
    end
    properties(Dependent=true,SetAccess=private,GetAccess=protected)
URLstr
Model
    end
    methods
        function h=Base(parent,objKind,objId)
            h.Parent=parent;
            h.ObjKind=objKind;
            h.ObjId=objId;
        end
        function out=char(h)
            out=h.URLstr;
        end
        function out=get.Model(h)
            if h.Parent(1)=='_'
                out='';
            else
                out=strtok(h.Parent,':');
            end
        end
        function out=get.URLstr(h)
            out=Simulink.URL.Base.constructURL(h.Parent,h.ObjKind,h.ObjId);
        end
        function out=getParent(h)
            out=h.Parent;
        end
        function out=getKind(h)
            out=h.ObjKind;
        end
        function out=getID(h)
            out=h.ObjId;
        end
        function out=isHilitable(h)%#ok<MANU>
            out=false;
        end
    end
    methods(Abstract)
        out=eval(h)
    end
    methods(Static)
        function out=constructURL(parent,objKind,objId)
            if nargin==1||(isempty(objKind)&&isempty(objId))
                out=parent;
            else
                out=[parent,'#',char(objKind),':',objId];
            end
        end
        function[parent,objKind,objId]=parse(str)
            [parent,next]=strtok(str,'#');
            if isempty(next),objKind=[];objId=[];return,end
            [objKind,objId]=strtok(next(2:end),':');
            try
                objKind=eval(['Simulink.URL.URLKind.',objKind]);
            catch me
                if strcmp(me.identifier,'MATLAB:subscripting:classHasNoPropertyOrMethod')
                    DAStudio.error('Simulink:utility:URLInvalidKind',objKind);
                end
                rethrow(me);
            end
            if~isempty(objId)
                objId=objId(2:end);
            end
        end
    end
end
