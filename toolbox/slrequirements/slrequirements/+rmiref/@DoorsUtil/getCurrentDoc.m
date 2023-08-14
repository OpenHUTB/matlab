function current=getCurrentDoc()

    rmiref.DoorsUtil.getApplication(true);

    current=rmidoors.getCurrentObj();
    if isempty(current)
        error(message('Slvnv:rmiref:DocCheckDoors:NoCurrentModule'));
    end
end
