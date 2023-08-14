// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   ExtensionMapper.java

package com.mathworks.internal.dws.client.v3;

import javax.xml.stream.XMLStreamReader;
import org.apache.axis2.databinding.ADBException;

// Referenced classes of package com.mathworks.internal.dws.client.v3:
//            ArrayOfArchitecture, GetUpdatedSoftwareWithinReleaseReturn, GetSoftwareProductInfoByLicenseAndArchitecturesReturn, ArrayOfSoftwareProductComponent, 
//            GetAllUpdatedSoftwareReturn, Relationship, ArrayOfError, ArrayOfMWMessage, 
//            Server, Error, GetUpdatedSoftwareWithinReleaseAndArchReturn, GetUpdatedSoftwareWithinPasscodeAndArchReturn, 
//            ArrayOfSoftware, ArrayOfString, ArrayOfSoftwareLicense, ArrayOfSoftwareProduct, 
//            SoftwareLicense, MWMessage, ArrayOfServer, ArrayOfRelationship, 
//            SoftwareProduct, Software, SoftwareProductComponent, Architecture, 
//            ArrayOfInteger, BitVer

public class ExtensionMapper
{

    public ExtensionMapper()
    {
    }

    public static Object getTypeObject(String namespaceURI, String typeName, XMLStreamReader reader)
        throws Exception
    {
        if("https://services.mathworks.com/dws3/services/DownloadService".equals(namespaceURI) && "ArrayOfArchitecture".equals(typeName))
            return ArrayOfArchitecture.Factory.parse(reader);
        if("https://services.mathworks.com/dws3/services/DownloadService".equals(namespaceURI) && "getUpdatedSoftwareWithinReleaseReturn".equals(typeName))
            return GetUpdatedSoftwareWithinReleaseReturn.Factory.parse(reader);
        if("https://services.mathworks.com/dws3/services/DownloadService".equals(namespaceURI) && "getSoftwareProductInfoByLicenseAndArchitecturesReturn".equals(typeName))
            return GetSoftwareProductInfoByLicenseAndArchitecturesReturn.Factory.parse(reader);
        if("https://services.mathworks.com/dws3/services/DownloadService".equals(namespaceURI) && "ArrayOfSoftwareProductComponent".equals(typeName))
            return ArrayOfSoftwareProductComponent.Factory.parse(reader);
        if("https://services.mathworks.com/dws3/services/DownloadService".equals(namespaceURI) && "getAllUpdatedSoftwareReturn".equals(typeName))
            return GetAllUpdatedSoftwareReturn.Factory.parse(reader);
        if("https://services.mathworks.com/dws3/services/DownloadService".equals(namespaceURI) && "Relationship".equals(typeName))
            return Relationship.Factory.parse(reader);
        if("https://services.mathworks.com/dws3/services/DownloadService".equals(namespaceURI) && "ArrayOfError".equals(typeName))
            return ArrayOfError.Factory.parse(reader);
        if("https://services.mathworks.com/dws3/services/DownloadService".equals(namespaceURI) && "ArrayOfMWMessage".equals(typeName))
            return ArrayOfMWMessage.Factory.parse(reader);
        if("https://services.mathworks.com/dws3/services/DownloadService".equals(namespaceURI) && "Server".equals(typeName))
            return Server.Factory.parse(reader);
        if("https://services.mathworks.com/dws3/services/DownloadService".equals(namespaceURI) && "Error".equals(typeName))
            return Error.Factory.parse(reader);
        if("https://services.mathworks.com/dws3/services/DownloadService".equals(namespaceURI) && "getUpdatedSoftwareWithinReleaseAndArchReturn".equals(typeName))
            return GetUpdatedSoftwareWithinReleaseAndArchReturn.Factory.parse(reader);
        if("https://services.mathworks.com/dws3/services/DownloadService".equals(namespaceURI) && "getUpdatedSoftwareWithinPasscodeAndArchReturn".equals(typeName))
            return GetUpdatedSoftwareWithinPasscodeAndArchReturn.Factory.parse(reader);
        if("https://services.mathworks.com/dws3/services/DownloadService".equals(namespaceURI) && "ArrayOfSoftware".equals(typeName))
            return ArrayOfSoftware.Factory.parse(reader);
        if("https://services.mathworks.com/dws3/services/DownloadService".equals(namespaceURI) && "ArrayOfString".equals(typeName))
            return ArrayOfString.Factory.parse(reader);
        if("https://services.mathworks.com/dws3/services/DownloadService".equals(namespaceURI) && "ArrayOfSoftwareLicense".equals(typeName))
            return ArrayOfSoftwareLicense.Factory.parse(reader);
        if("https://services.mathworks.com/dws3/services/DownloadService".equals(namespaceURI) && "ArrayOfSoftwareProduct".equals(typeName))
            return ArrayOfSoftwareProduct.Factory.parse(reader);
        if("https://services.mathworks.com/dws3/services/DownloadService".equals(namespaceURI) && "SoftwareLicense".equals(typeName))
            return SoftwareLicense.Factory.parse(reader);
        if("https://services.mathworks.com/dws3/services/DownloadService".equals(namespaceURI) && "MWMessage".equals(typeName))
            return MWMessage.Factory.parse(reader);
        if("https://services.mathworks.com/dws3/services/DownloadService".equals(namespaceURI) && "ArrayOfServer".equals(typeName))
            return ArrayOfServer.Factory.parse(reader);
        if("https://services.mathworks.com/dws3/services/DownloadService".equals(namespaceURI) && "ArrayOfRelationship".equals(typeName))
            return ArrayOfRelationship.Factory.parse(reader);
        if("https://services.mathworks.com/dws3/services/DownloadService".equals(namespaceURI) && "SoftwareProduct".equals(typeName))
            return SoftwareProduct.Factory.parse(reader);
        if("https://services.mathworks.com/dws3/services/DownloadService".equals(namespaceURI) && "Software".equals(typeName))
            return Software.Factory.parse(reader);
        if("https://services.mathworks.com/dws3/services/DownloadService".equals(namespaceURI) && "SoftwareProductComponent".equals(typeName))
            return SoftwareProductComponent.Factory.parse(reader);
        if("https://services.mathworks.com/dws3/services/DownloadService".equals(namespaceURI) && "Architecture".equals(typeName))
            return Architecture.Factory.parse(reader);
        if("https://services.mathworks.com/dws3/services/DownloadService".equals(namespaceURI) && "ArrayOfInteger".equals(typeName))
            return ArrayOfInteger.Factory.parse(reader);
        if("https://services.mathworks.com/dws3/services/DownloadService".equals(namespaceURI) && "BitVer".equals(typeName))
            return BitVer.Factory.parse(reader);
        else
            throw new ADBException((new StringBuilder()).append("Unsupported type ").append(namespaceURI).append(" ").append(typeName).toString());
    }
}
