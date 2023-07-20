function BackupObject(classObj)




    factory=evolutions.internal.session.SessionManager.getVisitorFactory;
    visitor=factory.getVisitor('Backup');
    evolutions.internal.classhandler.ClassHandler.visitObjects(classObj,visitor);
end
