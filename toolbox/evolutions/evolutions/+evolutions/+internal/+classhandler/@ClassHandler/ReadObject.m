function ReadObject(classObj)




    factory=evolutions.internal.session.SessionManager.getVisitorFactory;
    visitor=factory.getVisitor('Read');
    evolutions.internal.classhandler.ClassHandler.visitObjects(classObj,visitor);
end
