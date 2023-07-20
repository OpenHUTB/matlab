














classdef options<handle

    methods(Access=public)

        function obj=options()

            persistent pObj
            if~isempty(pObj)&&isvalid(pObj)
                obj=pObj;
                return
            end
            pObj=obj;
        end

        function disp(obj)

            f={...
            'JVMMaxHeapSize',...
'JVMInitHeapSize'
            };
            n=max(cellfun('length',f));
            pad=repmat(' ',1,n);
            fprintf('XML Comparison Options:\n\n')
            for jj=1:numel(f)
                this=[f{jj},pad];
                this=this(1:n);
                val=obj.(['get',f{jj}]);
                fprintf('  %s : %0.0f\n',this,val);
            end
        end

        function reset(obj)


            import com.mathworks.toolbox.rptgenxmlcomp.preferences.XMLPreferenceJVMMaxHeapSize;
            import com.mathworks.toolbox.rptgenxmlcomp.preferences.XMLPreferenceJVMInitHeapSize;
            obj.setJVMMaxHeapSize(...
            XMLPreferenceJVMMaxHeapSize.getInstance().getDefaultValue());
            obj.setJVMInitHeapSize(...
            XMLPreferenceJVMInitHeapSize.getInstance().getDefaultValue());
        end

        function setJVMMaxHeapSize(~,m)


            if~isnumeric(m)
                xmlcomp.internal.error('engine:ExtJVMMemoryProblem')
            end
            import com.mathworks.comparisons.prefs.ComparisonPreferenceManager;
            import com.mathworks.toolbox.rptgenxmlcomp.preferences.XMLPreferenceJVMMaxHeapSize;
            ComparisonPreferenceManager.getInstance().setValue(...
            XMLPreferenceJVMMaxHeapSize.getInstance(),java.lang.Integer(m));
        end

        function m=getJVMMaxHeapSize(~)
            import com.mathworks.comparisons.prefs.ComparisonPreferenceManager;
            import com.mathworks.toolbox.rptgenxmlcomp.preferences.XMLPreferenceJVMMaxHeapSize;
            m=ComparisonPreferenceManager.getInstance().getValue(...
            XMLPreferenceJVMMaxHeapSize.getInstance());
        end

        function setJVMInitHeapSize(~,m)


            if~isnumeric(m)
                xmlcomp.internal.error('engine:ExtJVMMemoryProblem')
            end
            import com.mathworks.comparisons.prefs.ComparisonPreferenceManager;
            import com.mathworks.toolbox.rptgenxmlcomp.preferences.XMLPreferenceJVMInitHeapSize;
            ComparisonPreferenceManager.getInstance().setValue(...
            XMLPreferenceJVMInitHeapSize.getInstance(),java.lang.Integer(m));
        end

        function m=getJVMInitHeapSize(~)
            import com.mathworks.comparisons.prefs.ComparisonPreferenceManager;
            import com.mathworks.toolbox.rptgenxmlcomp.preferences.XMLPreferenceJVMInitHeapSize;
            m=ComparisonPreferenceManager.getInstance().getValue(...
            XMLPreferenceJVMInitHeapSize.getInstance());
        end

    end

end
