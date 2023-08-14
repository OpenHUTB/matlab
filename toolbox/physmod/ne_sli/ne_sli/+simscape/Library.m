classdef Library<handle




    properties(SetAccess=private)
        Source='';
        SourceExists=false;
    end
    properties
        Name='';
        Annotation='';
        Hidden=false;
        ShowName=false;
        ShowIcon=true;
    end
    methods
        function this=Library(sourceFile)
            if exist(sourceFile,'file')
                this.SourceExists=true;
            else
                this.SourceExists=false;
            end
            sourceDir=fileparts(sourceFile);
            this.Source=sourceDir;
        end

        function disp(this)
            annotation=this.Annotation;
            if isempty(annotation)
                annotation='''''';
            end
            fprintf('%15s : %s\n','Name',this.Name);
            fprintf('%15s : %s\n','Annotation',annotation);
            fprintf('%15s : %d\n','Hidden',this.Hidden);
            fprintf('%15s : %d\n','ShowName',this.ShowName);
            fprintf('%15s : %d\n','ShowIcon',this.ShowIcon);
        end


        function this=set.Annotation(this,val)
            if~ischar(val)
                pm_error('physmod:ne_sli:library:Char','Annotation');
            end
            this.Annotation=val;
        end

        function this=set.Hidden(this,val)
            if~islogical(val)
                pm_error('physmod:ne_sli:library:Boolean','Hidden');
            end
            this.Hidden=val;
        end

        function this=set.ShowName(this,val)
            if~islogical(val)
                pm_error('physmod:ne_sli:library:Boolean','ShowName');
            end
            this.ShowName=val;
        end

        function this=set.ShowIcon(this,val)
            if~islogical(val)
                pm_error('physmod:ne_sli:library:Boolean','ShowIcon');
            end
            this.ShowIcon=val;
        end


    end


    properties(Hidden=true)
        version(1,1)simscape.versioning.version
    end
    properties(Hidden=true,SetAccess=private)
        forwards={};
    end
    methods(Hidden=true)
        function obj=add(obj,fwd)
            if~isscalar(fwd)||...
                isempty(fwd)||...
                ~(isa(fwd,'simscape.versioning.Forward')||...
                isa(fwd,'simscape.versioning.Transform'))

                pm_error('physmod:ne_sli:versioning:InvalidType');
            end
            validate(fwd);
            obj.forwards{end+1}=fwd;
        end
    end
end
