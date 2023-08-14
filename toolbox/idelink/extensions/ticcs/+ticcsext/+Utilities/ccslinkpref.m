function prefVal=ccslinkpref(action,varargin)




    groupName=ticcsext.Utilities.LfCProperty('ccslinkpref-groupname');
    prefVal=linkfoundation.util.linkpref(action,groupName,varargin{:});


