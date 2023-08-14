function listTflInfo(h,varargin)








    refreshCRL(h);

    if nargin>1
        TflName=varargin{1};
        tfl=coder.internal.getTfl(h,TflName);
        prettyPrint(tfl);
    else
        for j=1:length(h.TargetFunctionLibraries)
            tfl=h.TargetFunctionLibraries(j);
            prettyPrint(tfl);
        end
    end

    disp(' ');
    disp('======================= End of List =============================');


    function prettyPrint(tflhdl)
        disp(' ');
        disp('====================== TFL Information ==========================');
        disp(' ');
        disp(['Name:            ',tflhdl.Name]);

        txtAlias='';
        for i=1:length(tflhdl.Alias)
            txtAlias=[txtAlias,tflhdl.Alias{i},'; '];%#ok
        end
        if isempty(txtAlias)
            txtAlias='(None)';
        end
        disp(['Alias(es):       ',txtAlias]);

        txtBaseTfl=tflhdl.BaseTfl;
        if isempty(txtBaseTfl)
            txtBaseTfl='(None)';
        end
        disp(['Base TFL:        ',txtBaseTfl]);

        txtHwType='';
        for i=1:length(tflhdl.TargetHWDeviceType)
            txtHwType=[txtHwType,tflhdl.TargetHWDeviceType{i},'; '];%#ok
        end
        if isempty(txtHwType)
            txtHwType='(None)';
        end
        disp(['Supported HW(s): ',txtHwType]);

        txtTbl='';
        for i=1:length(tflhdl.TableList)
            txtTbl=[txtTbl,tflhdl.TableList{i},'; '];%#ok
        end
        if isempty(txtTbl)
            txtTbl='(None)';
        end
        disp(['TFL Table(s):    ',txtTbl]);
