


classdef Rule<dynamicprops
    methods


        function rule=Rule(varargin)
            temp={'enable',true,varargin{:}};%#ok<CCAT>
            for itr=1:2:length(temp)
                rule.addprop(temp{itr});
                rule.(temp{itr})=temp{itr+1};
            end


            mlock;

        end
        function disp(this)
            P=properties(this);
            for itr=1:length(P)
                disp([P{itr},' : ',coder.internal.tools.TML.tostr(this.(P{itr}))])
            end
        end
    end
end
