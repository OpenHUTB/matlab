classdef(Abstract)ImportDialogView<handle





    properties(Abstract,SetAccess=private)
simlogVariablePicked
    end

    events



ImportDialogCancelled



ImportDialogDataImported



ImportDialogDataRefreshed
    end

    methods(Abstract)


        open(this)
    end

end