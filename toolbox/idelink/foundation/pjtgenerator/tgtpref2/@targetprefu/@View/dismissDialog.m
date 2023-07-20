function dismissDialog(hView,hDlg,name)%#ok<INUSL>




    assert(~isempty(strmatch(name,{'Warning','Error','Question'},'exact')),DAStudio.message('ERRORHANDLER:tgtpref:DataInconsistent'));
    delete(hDlg);