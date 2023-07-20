



function initializeReader(obj)

    obj.fUserReader=slci.view.data.DataReader(...
    obj.fDDConnection,'Results.userTable');
    obj.fBlockReader=slci.view.data.DataReader(...
    obj.fDDConnection,'Results.blockTable');
    obj.fCodeReader=slci.view.data.DataReader(...
    obj.fDDConnection,'Results.codeTable');
