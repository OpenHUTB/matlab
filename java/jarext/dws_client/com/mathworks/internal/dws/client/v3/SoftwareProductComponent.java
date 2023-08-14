// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   SoftwareProductComponent.java

package com.mathworks.internal.dws.client.v3;

import java.util.ArrayList;
import java.util.Vector;
import javax.xml.namespace.NamespaceContext;
import javax.xml.namespace.QName;
import javax.xml.stream.*;
import org.apache.axiom.om.OMElement;
import org.apache.axiom.om.OMFactory;
import org.apache.axiom.om.impl.llom.OMSourcedElementImpl;
import org.apache.axis2.databinding.*;
import org.apache.axis2.databinding.utils.BeanUtil;
import org.apache.axis2.databinding.utils.ConverterUtil;
import org.apache.axis2.databinding.utils.reader.ADBXMLStreamReaderImpl;
import org.apache.axis2.databinding.utils.writer.MTOMAwareXMLStreamWriter;

// Referenced classes of package com.mathworks.internal.dws.client.v3:
//            ArrayOfString, ArrayOfInteger, ExtensionMapper

public class SoftwareProductComponent
    implements ADBBean
{
    public static class Factory
    {

        public static SoftwareProductComponent parse(XMLStreamReader reader)
            throws Exception
        {
            SoftwareProductComponent object;
            object = new SoftwareProductComponent();
            String nillableValue = null;
            String prefix = "";
            String namespaceuri = "";
            Vector handledAttributes;
            String content;
            try
            {
                for(; !reader.isStartElement() && !reader.isEndElement(); reader.next());
                if(reader.getAttributeValue("http://www.w3.org/2001/XMLSchema-instance", "type") != null)
                {
                    String fullTypeName = reader.getAttributeValue("http://www.w3.org/2001/XMLSchema-instance", "type");
                    if(fullTypeName != null)
                    {
                        String nsPrefix = null;
                        if(fullTypeName.indexOf(":") > -1)
                            nsPrefix = fullTypeName.substring(0, fullTypeName.indexOf(":"));
                        nsPrefix = nsPrefix != null ? nsPrefix : "";
                        String type = fullTypeName.substring(fullTypeName.indexOf(":") + 1);
                        if(!"SoftwareProductComponent".equals(type))
                        {
                            String nsUri = reader.getNamespaceContext().getNamespaceURI(nsPrefix);
                            return (SoftwareProductComponent)ExtensionMapper.getTypeObject(nsUri, type, reader);
                        }
                    }
                }
            }
            catch(XMLStreamException e)
            {
                throw new Exception(e);
            }
            handledAttributes = new Vector();
            reader.next();
            for(; !reader.isStartElement() && !reader.isEndElement(); reader.next());
            if(reader.isStartElement() && (new QName("https://services.mathworks.com/dws3/services/DownloadService", "architectureIds")).equals(reader.getName()))
            {
                nillableValue = reader.getAttributeValue("http://www.w3.org/2001/XMLSchema-instance", "nil");
                if("true".equals(nillableValue) || "1".equals(nillableValue))
                {
                    object.setArchitectureIds(null);
                    reader.next();
                    reader.next();
                } else
                {
                    object.setArchitectureIds(ArrayOfString.Factory.parse(reader));
                    reader.next();
                }
            } else
            {
                throw new ADBException((new StringBuilder()).append("Unexpected subelement ").append(reader.getLocalName()).toString());
            }
            for(; !reader.isStartElement() && !reader.isEndElement(); reader.next());
            if(reader.isStartElement() && (new QName("https://services.mathworks.com/dws3/services/DownloadService", "componentPath")).equals(reader.getName()))
            {
                nillableValue = reader.getAttributeValue("http://www.w3.org/2001/XMLSchema-instance", "nil");
                if(!"true".equals(nillableValue) && !"1".equals(nillableValue))
                {
                    content = reader.getElementText();
                    object.setComponentPath(ConverterUtil.convertToString(content));
                } else
                {
                    reader.getElementText();
                }
                reader.next();
            } else
            {
                throw new ADBException((new StringBuilder()).append("Unexpected subelement ").append(reader.getLocalName()).toString());
            }
            for(; !reader.isStartElement() && !reader.isEndElement(); reader.next());
            if(reader.isStartElement() && (new QName("https://services.mathworks.com/dws3/services/DownloadService", "fileName")).equals(reader.getName()))
            {
                nillableValue = reader.getAttributeValue("http://www.w3.org/2001/XMLSchema-instance", "nil");
                if(!"true".equals(nillableValue) && !"1".equals(nillableValue))
                {
                    content = reader.getElementText();
                    object.setFileName(ConverterUtil.convertToString(content));
                } else
                {
                    reader.getElementText();
                }
                reader.next();
            } else
            {
                throw new ADBException((new StringBuilder()).append("Unexpected subelement ").append(reader.getLocalName()).toString());
            }
            for(; !reader.isStartElement() && !reader.isEndElement(); reader.next());
            if(reader.isStartElement() && (new QName("https://services.mathworks.com/dws3/services/DownloadService", "filePath")).equals(reader.getName()))
            {
                nillableValue = reader.getAttributeValue("http://www.w3.org/2001/XMLSchema-instance", "nil");
                if(!"true".equals(nillableValue) && !"1".equals(nillableValue))
                {
                    content = reader.getElementText();
                    object.setFilePath(ConverterUtil.convertToString(content));
                } else
                {
                    reader.getElementText();
                }
                reader.next();
            } else
            {
                throw new ADBException((new StringBuilder()).append("Unexpected subelement ").append(reader.getLocalName()).toString());
            }
            for(; !reader.isStartElement() && !reader.isEndElement(); reader.next());
            if(reader.isStartElement() && (new QName("https://services.mathworks.com/dws3/services/DownloadService", "key")).equals(reader.getName()))
            {
                content = reader.getElementText();
                object.setKey(ConverterUtil.convertToInt(content));
                reader.next();
            } else
            {
                throw new ADBException((new StringBuilder()).append("Unexpected subelement ").append(reader.getLocalName()).toString());
            }
            for(; !reader.isStartElement() && !reader.isEndElement(); reader.next());
            if(reader.isStartElement() && (new QName("https://services.mathworks.com/dws3/services/DownloadService", "md5CheckSum")).equals(reader.getName()))
            {
                nillableValue = reader.getAttributeValue("http://www.w3.org/2001/XMLSchema-instance", "nil");
                if(!"true".equals(nillableValue) && !"1".equals(nillableValue))
                {
                    content = reader.getElementText();
                    object.setMd5CheckSum(ConverterUtil.convertToString(content));
                } else
                {
                    reader.getElementText();
                }
                reader.next();
            } else
            {
                throw new ADBException((new StringBuilder()).append("Unexpected subelement ").append(reader.getLocalName()).toString());
            }
            for(; !reader.isStartElement() && !reader.isEndElement(); reader.next());
            if(reader.isStartElement() && (new QName("https://services.mathworks.com/dws3/services/DownloadService", "name")).equals(reader.getName()))
            {
                nillableValue = reader.getAttributeValue("http://www.w3.org/2001/XMLSchema-instance", "nil");
                if(!"true".equals(nillableValue) && !"1".equals(nillableValue))
                {
                    content = reader.getElementText();
                    object.setName(ConverterUtil.convertToString(content));
                } else
                {
                    reader.getElementText();
                }
                reader.next();
            } else
            {
                throw new ADBException((new StringBuilder()).append("Unexpected subelement ").append(reader.getLocalName()).toString());
            }
            for(; !reader.isStartElement() && !reader.isEndElement(); reader.next());
            if(reader.isStartElement() && (new QName("https://services.mathworks.com/dws3/services/DownloadService", "serverId")).equals(reader.getName()))
            {
                nillableValue = reader.getAttributeValue("http://www.w3.org/2001/XMLSchema-instance", "nil");
                if(!"true".equals(nillableValue) && !"1".equals(nillableValue))
                {
                    content = reader.getElementText();
                    object.setServerId(ConverterUtil.convertToString(content));
                } else
                {
                    reader.getElementText();
                }
                reader.next();
            } else
            {
                throw new ADBException((new StringBuilder()).append("Unexpected subelement ").append(reader.getLocalName()).toString());
            }
            for(; !reader.isStartElement() && !reader.isEndElement(); reader.next());
            if(reader.isStartElement() && (new QName("https://services.mathworks.com/dws3/services/DownloadService", "size")).equals(reader.getName()))
            {
                content = reader.getElementText();
                object.setSize(ConverterUtil.convertToInt(content));
                reader.next();
            } else
            {
                throw new ADBException((new StringBuilder()).append("Unexpected subelement ").append(reader.getLocalName()).toString());
            }
            for(; !reader.isStartElement() && !reader.isEndElement(); reader.next());
            if(reader.isStartElement() && (new QName("https://services.mathworks.com/dws3/services/DownloadService", "sizeOnDisk")).equals(reader.getName()))
            {
                nillableValue = reader.getAttributeValue("http://www.w3.org/2001/XMLSchema-instance", "nil");
                if("true".equals(nillableValue) || "1".equals(nillableValue))
                {
                    object.setSizeOnDisk(null);
                    reader.next();
                    reader.next();
                } else
                {
                    object.setSizeOnDisk(ArrayOfInteger.Factory.parse(reader));
                    reader.next();
                }
            } else
            {
                throw new ADBException((new StringBuilder()).append("Unexpected subelement ").append(reader.getLocalName()).toString());
            }
            for(; !reader.isStartElement() && !reader.isEndElement(); reader.next());
            if(reader.isStartElement() && (new QName("https://services.mathworks.com/dws3/services/DownloadService", "type")).equals(reader.getName()))
            {
                nillableValue = reader.getAttributeValue("http://www.w3.org/2001/XMLSchema-instance", "nil");
                if(!"true".equals(nillableValue) && !"1".equals(nillableValue))
                {
                    content = reader.getElementText();
                    object.setType(ConverterUtil.convertToString(content));
                } else
                {
                    reader.getElementText();
                }
                reader.next();
            } else
            {
                throw new ADBException((new StringBuilder()).append("Unexpected subelement ").append(reader.getLocalName()).toString());
            }
            for(; !reader.isStartElement() && !reader.isEndElement(); reader.next());
            if(reader.isStartElement() && (new QName("https://services.mathworks.com/dws3/services/DownloadService", "uniqueId")).equals(reader.getName()))
            {
                nillableValue = reader.getAttributeValue("http://www.w3.org/2001/XMLSchema-instance", "nil");
                if(!"true".equals(nillableValue) && !"1".equals(nillableValue))
                {
                    content = reader.getElementText();
                    object.setUniqueId(ConverterUtil.convertToString(content));
                } else
                {
                    reader.getElementText();
                }
                reader.next();
            } else
            {
                throw new ADBException((new StringBuilder()).append("Unexpected subelement ").append(reader.getLocalName()).toString());
            }
            for(; !reader.isStartElement() && !reader.isEndElement(); reader.next());
            if(reader.isStartElement())
                throw new ADBException((new StringBuilder()).append("Unexpected subelement ").append(reader.getLocalName()).toString());
            return object;
        }

        public Factory()
        {
        }
    }


    public SoftwareProductComponent()
    {
    }

    private static String generatePrefix(String namespace)
    {
        if(namespace.equals("https://services.mathworks.com/dws3/services/DownloadService"))
            return "ns1";
        else
            return BeanUtil.getUniquePrefix();
    }

    public ArrayOfString getArchitectureIds()
    {
        return localArchitectureIds;
    }

    public void setArchitectureIds(ArrayOfString param)
    {
        localArchitectureIds = param;
    }

    public String getComponentPath()
    {
        return localComponentPath;
    }

    public void setComponentPath(String param)
    {
        localComponentPath = param;
    }

    public String getFileName()
    {
        return localFileName;
    }

    public void setFileName(String param)
    {
        localFileName = param;
    }

    public String getFilePath()
    {
        return localFilePath;
    }

    public void setFilePath(String param)
    {
        localFilePath = param;
    }

    public int getKey()
    {
        return localKey;
    }

    public void setKey(int param)
    {
        localKey = param;
    }

    public String getMd5CheckSum()
    {
        return localMd5CheckSum;
    }

    public void setMd5CheckSum(String param)
    {
        localMd5CheckSum = param;
    }

    public String getName()
    {
        return localName;
    }

    public void setName(String param)
    {
        localName = param;
    }

    public String getServerId()
    {
        return localServerId;
    }

    public void setServerId(String param)
    {
        localServerId = param;
    }

    public int getSize()
    {
        return localSize;
    }

    public void setSize(int param)
    {
        localSize = param;
    }

    public ArrayOfInteger getSizeOnDisk()
    {
        return localSizeOnDisk;
    }

    public void setSizeOnDisk(ArrayOfInteger param)
    {
        localSizeOnDisk = param;
    }

    public String getType()
    {
        return localType;
    }

    public void setType(String param)
    {
        localType = param;
    }

    public String getUniqueId()
    {
        return localUniqueId;
    }

    public void setUniqueId(String param)
    {
        localUniqueId = param;
    }

    public static boolean isReaderMTOMAware(XMLStreamReader reader)
    {
        boolean isReaderMTOMAware = false;
        try
        {
            isReaderMTOMAware = Boolean.TRUE.equals(reader.getProperty("IsDatahandlersAwareParsing"));
        }
        catch(IllegalArgumentException e)
        {
            isReaderMTOMAware = false;
        }
        return isReaderMTOMAware;
    }

    public OMElement getOMElement(QName parentQName, OMFactory factory)
        throws ADBException
    {
        org.apache.axiom.om.OMDataSource dataSource = new ADBDataSource(parentQName, factory) {

            public void serialize(MTOMAwareXMLStreamWriter xmlWriter)
                throws XMLStreamException
            {
                SoftwareProductComponent.this.serialize(parentQName, factory, xmlWriter);
            }

            final OMFactory val$factory;
            final SoftwareProductComponent this$0;

            
            {
                this$0 = SoftwareProductComponent.this;
                factory = omfactory;
                super(x0, x1);
            }
        }
;
        return new OMSourcedElementImpl(parentQName, factory, dataSource);
    }

    public void serialize(QName parentQName, OMFactory factory, MTOMAwareXMLStreamWriter xmlWriter)
        throws XMLStreamException, ADBException
    {
        serialize(parentQName, factory, xmlWriter, false);
    }

    public void serialize(QName parentQName, OMFactory factory, MTOMAwareXMLStreamWriter xmlWriter, boolean serializeType)
        throws XMLStreamException, ADBException
    {
        String prefix = null;
        String namespace = null;
        prefix = parentQName.getPrefix();
        namespace = parentQName.getNamespaceURI();
        if(namespace != null && namespace.trim().length() > 0)
        {
            String writerPrefix = xmlWriter.getPrefix(namespace);
            if(writerPrefix != null)
            {
                xmlWriter.writeStartElement(namespace, parentQName.getLocalPart());
            } else
            {
                if(prefix == null)
                    prefix = generatePrefix(namespace);
                xmlWriter.writeStartElement(prefix, parentQName.getLocalPart(), namespace);
                xmlWriter.writeNamespace(prefix, namespace);
                xmlWriter.setPrefix(prefix, namespace);
            }
        } else
        {
            xmlWriter.writeStartElement(parentQName.getLocalPart());
        }
        if(serializeType)
        {
            String namespacePrefix = registerPrefix(xmlWriter, "https://services.mathworks.com/dws3/services/DownloadService");
            if(namespacePrefix != null && namespacePrefix.trim().length() > 0)
                writeAttribute("xsi", "http://www.w3.org/2001/XMLSchema-instance", "type", (new StringBuilder()).append(namespacePrefix).append(":SoftwareProductComponent").toString(), xmlWriter);
            else
                writeAttribute("xsi", "http://www.w3.org/2001/XMLSchema-instance", "type", "SoftwareProductComponent", xmlWriter);
        }
        if(localArchitectureIds == null)
        {
            String namespace2 = "https://services.mathworks.com/dws3/services/DownloadService";
            if(!namespace2.equals(""))
            {
                String prefix2 = xmlWriter.getPrefix(namespace2);
                if(prefix2 == null)
                {
                    prefix2 = generatePrefix(namespace2);
                    xmlWriter.writeStartElement(prefix2, "architectureIds", namespace2);
                    xmlWriter.writeNamespace(prefix2, namespace2);
                    xmlWriter.setPrefix(prefix2, namespace2);
                } else
                {
                    xmlWriter.writeStartElement(namespace2, "architectureIds");
                }
            } else
            {
                xmlWriter.writeStartElement("architectureIds");
            }
            writeAttribute("xsi", "http://www.w3.org/2001/XMLSchema-instance", "nil", "1", xmlWriter);
            xmlWriter.writeEndElement();
        } else
        {
            localArchitectureIds.serialize(new QName("https://services.mathworks.com/dws3/services/DownloadService", "architectureIds"), factory, xmlWriter);
        }
        namespace = "https://services.mathworks.com/dws3/services/DownloadService";
        if(!namespace.equals(""))
        {
            prefix = xmlWriter.getPrefix(namespace);
            if(prefix == null)
            {
                prefix = generatePrefix(namespace);
                xmlWriter.writeStartElement(prefix, "componentPath", namespace);
                xmlWriter.writeNamespace(prefix, namespace);
                xmlWriter.setPrefix(prefix, namespace);
            } else
            {
                xmlWriter.writeStartElement(namespace, "componentPath");
            }
        } else
        {
            xmlWriter.writeStartElement("componentPath");
        }
        if(localComponentPath == null)
            writeAttribute("xsi", "http://www.w3.org/2001/XMLSchema-instance", "nil", "1", xmlWriter);
        else
            xmlWriter.writeCharacters(localComponentPath);
        xmlWriter.writeEndElement();
        namespace = "https://services.mathworks.com/dws3/services/DownloadService";
        if(!namespace.equals(""))
        {
            prefix = xmlWriter.getPrefix(namespace);
            if(prefix == null)
            {
                prefix = generatePrefix(namespace);
                xmlWriter.writeStartElement(prefix, "fileName", namespace);
                xmlWriter.writeNamespace(prefix, namespace);
                xmlWriter.setPrefix(prefix, namespace);
            } else
            {
                xmlWriter.writeStartElement(namespace, "fileName");
            }
        } else
        {
            xmlWriter.writeStartElement("fileName");
        }
        if(localFileName == null)
            writeAttribute("xsi", "http://www.w3.org/2001/XMLSchema-instance", "nil", "1", xmlWriter);
        else
            xmlWriter.writeCharacters(localFileName);
        xmlWriter.writeEndElement();
        namespace = "https://services.mathworks.com/dws3/services/DownloadService";
        if(!namespace.equals(""))
        {
            prefix = xmlWriter.getPrefix(namespace);
            if(prefix == null)
            {
                prefix = generatePrefix(namespace);
                xmlWriter.writeStartElement(prefix, "filePath", namespace);
                xmlWriter.writeNamespace(prefix, namespace);
                xmlWriter.setPrefix(prefix, namespace);
            } else
            {
                xmlWriter.writeStartElement(namespace, "filePath");
            }
        } else
        {
            xmlWriter.writeStartElement("filePath");
        }
        if(localFilePath == null)
            writeAttribute("xsi", "http://www.w3.org/2001/XMLSchema-instance", "nil", "1", xmlWriter);
        else
            xmlWriter.writeCharacters(localFilePath);
        xmlWriter.writeEndElement();
        namespace = "https://services.mathworks.com/dws3/services/DownloadService";
        if(!namespace.equals(""))
        {
            prefix = xmlWriter.getPrefix(namespace);
            if(prefix == null)
            {
                prefix = generatePrefix(namespace);
                xmlWriter.writeStartElement(prefix, "key", namespace);
                xmlWriter.writeNamespace(prefix, namespace);
                xmlWriter.setPrefix(prefix, namespace);
            } else
            {
                xmlWriter.writeStartElement(namespace, "key");
            }
        } else
        {
            xmlWriter.writeStartElement("key");
        }
        if(localKey == 0x80000000)
            throw new ADBException("key cannot be null!!");
        xmlWriter.writeCharacters(ConverterUtil.convertToString(localKey));
        xmlWriter.writeEndElement();
        namespace = "https://services.mathworks.com/dws3/services/DownloadService";
        if(!namespace.equals(""))
        {
            prefix = xmlWriter.getPrefix(namespace);
            if(prefix == null)
            {
                prefix = generatePrefix(namespace);
                xmlWriter.writeStartElement(prefix, "md5CheckSum", namespace);
                xmlWriter.writeNamespace(prefix, namespace);
                xmlWriter.setPrefix(prefix, namespace);
            } else
            {
                xmlWriter.writeStartElement(namespace, "md5CheckSum");
            }
        } else
        {
            xmlWriter.writeStartElement("md5CheckSum");
        }
        if(localMd5CheckSum == null)
            writeAttribute("xsi", "http://www.w3.org/2001/XMLSchema-instance", "nil", "1", xmlWriter);
        else
            xmlWriter.writeCharacters(localMd5CheckSum);
        xmlWriter.writeEndElement();
        namespace = "https://services.mathworks.com/dws3/services/DownloadService";
        if(!namespace.equals(""))
        {
            prefix = xmlWriter.getPrefix(namespace);
            if(prefix == null)
            {
                prefix = generatePrefix(namespace);
                xmlWriter.writeStartElement(prefix, "name", namespace);
                xmlWriter.writeNamespace(prefix, namespace);
                xmlWriter.setPrefix(prefix, namespace);
            } else
            {
                xmlWriter.writeStartElement(namespace, "name");
            }
        } else
        {
            xmlWriter.writeStartElement("name");
        }
        if(localName == null)
            writeAttribute("xsi", "http://www.w3.org/2001/XMLSchema-instance", "nil", "1", xmlWriter);
        else
            xmlWriter.writeCharacters(localName);
        xmlWriter.writeEndElement();
        namespace = "https://services.mathworks.com/dws3/services/DownloadService";
        if(!namespace.equals(""))
        {
            prefix = xmlWriter.getPrefix(namespace);
            if(prefix == null)
            {
                prefix = generatePrefix(namespace);
                xmlWriter.writeStartElement(prefix, "serverId", namespace);
                xmlWriter.writeNamespace(prefix, namespace);
                xmlWriter.setPrefix(prefix, namespace);
            } else
            {
                xmlWriter.writeStartElement(namespace, "serverId");
            }
        } else
        {
            xmlWriter.writeStartElement("serverId");
        }
        if(localServerId == null)
            writeAttribute("xsi", "http://www.w3.org/2001/XMLSchema-instance", "nil", "1", xmlWriter);
        else
            xmlWriter.writeCharacters(localServerId);
        xmlWriter.writeEndElement();
        namespace = "https://services.mathworks.com/dws3/services/DownloadService";
        if(!namespace.equals(""))
        {
            prefix = xmlWriter.getPrefix(namespace);
            if(prefix == null)
            {
                prefix = generatePrefix(namespace);
                xmlWriter.writeStartElement(prefix, "size", namespace);
                xmlWriter.writeNamespace(prefix, namespace);
                xmlWriter.setPrefix(prefix, namespace);
            } else
            {
                xmlWriter.writeStartElement(namespace, "size");
            }
        } else
        {
            xmlWriter.writeStartElement("size");
        }
        if(localSize == 0x80000000)
            throw new ADBException("size cannot be null!!");
        xmlWriter.writeCharacters(ConverterUtil.convertToString(localSize));
        xmlWriter.writeEndElement();
        if(localSizeOnDisk == null)
        {
            String namespace2 = "https://services.mathworks.com/dws3/services/DownloadService";
            if(!namespace2.equals(""))
            {
                String prefix2 = xmlWriter.getPrefix(namespace2);
                if(prefix2 == null)
                {
                    prefix2 = generatePrefix(namespace2);
                    xmlWriter.writeStartElement(prefix2, "sizeOnDisk", namespace2);
                    xmlWriter.writeNamespace(prefix2, namespace2);
                    xmlWriter.setPrefix(prefix2, namespace2);
                } else
                {
                    xmlWriter.writeStartElement(namespace2, "sizeOnDisk");
                }
            } else
            {
                xmlWriter.writeStartElement("sizeOnDisk");
            }
            writeAttribute("xsi", "http://www.w3.org/2001/XMLSchema-instance", "nil", "1", xmlWriter);
            xmlWriter.writeEndElement();
        } else
        {
            localSizeOnDisk.serialize(new QName("https://services.mathworks.com/dws3/services/DownloadService", "sizeOnDisk"), factory, xmlWriter);
        }
        namespace = "https://services.mathworks.com/dws3/services/DownloadService";
        if(!namespace.equals(""))
        {
            prefix = xmlWriter.getPrefix(namespace);
            if(prefix == null)
            {
                prefix = generatePrefix(namespace);
                xmlWriter.writeStartElement(prefix, "type", namespace);
                xmlWriter.writeNamespace(prefix, namespace);
                xmlWriter.setPrefix(prefix, namespace);
            } else
            {
                xmlWriter.writeStartElement(namespace, "type");
            }
        } else
        {
            xmlWriter.writeStartElement("type");
        }
        if(localType == null)
            writeAttribute("xsi", "http://www.w3.org/2001/XMLSchema-instance", "nil", "1", xmlWriter);
        else
            xmlWriter.writeCharacters(localType);
        xmlWriter.writeEndElement();
        namespace = "https://services.mathworks.com/dws3/services/DownloadService";
        if(!namespace.equals(""))
        {
            prefix = xmlWriter.getPrefix(namespace);
            if(prefix == null)
            {
                prefix = generatePrefix(namespace);
                xmlWriter.writeStartElement(prefix, "uniqueId", namespace);
                xmlWriter.writeNamespace(prefix, namespace);
                xmlWriter.setPrefix(prefix, namespace);
            } else
            {
                xmlWriter.writeStartElement(namespace, "uniqueId");
            }
        } else
        {
            xmlWriter.writeStartElement("uniqueId");
        }
        if(localUniqueId == null)
            writeAttribute("xsi", "http://www.w3.org/2001/XMLSchema-instance", "nil", "1", xmlWriter);
        else
            xmlWriter.writeCharacters(localUniqueId);
        xmlWriter.writeEndElement();
        xmlWriter.writeEndElement();
    }

    private void writeAttribute(String prefix, String namespace, String attName, String attValue, XMLStreamWriter xmlWriter)
        throws XMLStreamException
    {
        if(xmlWriter.getPrefix(namespace) == null)
        {
            xmlWriter.writeNamespace(prefix, namespace);
            xmlWriter.setPrefix(prefix, namespace);
        }
        xmlWriter.writeAttribute(namespace, attName, attValue);
    }

    private void writeAttribute(String namespace, String attName, String attValue, XMLStreamWriter xmlWriter)
        throws XMLStreamException
    {
        if(namespace.equals(""))
        {
            xmlWriter.writeAttribute(attName, attValue);
        } else
        {
            registerPrefix(xmlWriter, namespace);
            xmlWriter.writeAttribute(namespace, attName, attValue);
        }
    }

    private void writeQNameAttribute(String namespace, String attName, QName qname, XMLStreamWriter xmlWriter)
        throws XMLStreamException
    {
        String attributeNamespace = qname.getNamespaceURI();
        String attributePrefix = xmlWriter.getPrefix(attributeNamespace);
        if(attributePrefix == null)
            attributePrefix = registerPrefix(xmlWriter, attributeNamespace);
        String attributeValue;
        if(attributePrefix.trim().length() > 0)
            attributeValue = (new StringBuilder()).append(attributePrefix).append(":").append(qname.getLocalPart()).toString();
        else
            attributeValue = qname.getLocalPart();
        if(namespace.equals(""))
        {
            xmlWriter.writeAttribute(attName, attributeValue);
        } else
        {
            registerPrefix(xmlWriter, namespace);
            xmlWriter.writeAttribute(namespace, attName, attributeValue);
        }
    }

    private void writeQName(QName qname, XMLStreamWriter xmlWriter)
        throws XMLStreamException
    {
        String namespaceURI = qname.getNamespaceURI();
        if(namespaceURI != null)
        {
            String prefix = xmlWriter.getPrefix(namespaceURI);
            if(prefix == null)
            {
                prefix = generatePrefix(namespaceURI);
                xmlWriter.writeNamespace(prefix, namespaceURI);
                xmlWriter.setPrefix(prefix, namespaceURI);
            }
            if(prefix.trim().length() > 0)
                xmlWriter.writeCharacters((new StringBuilder()).append(prefix).append(":").append(ConverterUtil.convertToString(qname)).toString());
            else
                xmlWriter.writeCharacters(ConverterUtil.convertToString(qname));
        } else
        {
            xmlWriter.writeCharacters(ConverterUtil.convertToString(qname));
        }
    }

    private void writeQNames(QName qnames[], XMLStreamWriter xmlWriter)
        throws XMLStreamException
    {
        if(qnames != null)
        {
            StringBuffer stringToWrite = new StringBuffer();
            String namespaceURI = null;
            String prefix = null;
            for(int i = 0; i < qnames.length; i++)
            {
                if(i > 0)
                    stringToWrite.append(" ");
                namespaceURI = qnames[i].getNamespaceURI();
                if(namespaceURI != null)
                {
                    prefix = xmlWriter.getPrefix(namespaceURI);
                    if(prefix == null || prefix.length() == 0)
                    {
                        prefix = generatePrefix(namespaceURI);
                        xmlWriter.writeNamespace(prefix, namespaceURI);
                        xmlWriter.setPrefix(prefix, namespaceURI);
                    }
                    if(prefix.trim().length() > 0)
                        stringToWrite.append(prefix).append(":").append(ConverterUtil.convertToString(qnames[i]));
                    else
                        stringToWrite.append(ConverterUtil.convertToString(qnames[i]));
                } else
                {
                    stringToWrite.append(ConverterUtil.convertToString(qnames[i]));
                }
            }

            xmlWriter.writeCharacters(stringToWrite.toString());
        }
    }

    private String registerPrefix(XMLStreamWriter xmlWriter, String namespace)
        throws XMLStreamException
    {
        String prefix = xmlWriter.getPrefix(namespace);
        if(prefix == null)
        {
            for(prefix = generatePrefix(namespace); xmlWriter.getNamespaceContext().getNamespaceURI(prefix) != null; prefix = BeanUtil.getUniquePrefix());
            xmlWriter.writeNamespace(prefix, namespace);
            xmlWriter.setPrefix(prefix, namespace);
        }
        return prefix;
    }

    public XMLStreamReader getPullParser(QName qName)
        throws ADBException
    {
        ArrayList elementList = new ArrayList();
        ArrayList attribList = new ArrayList();
        elementList.add(new QName("https://services.mathworks.com/dws3/services/DownloadService", "architectureIds"));
        elementList.add(localArchitectureIds != null ? ((Object) (localArchitectureIds)) : null);
        elementList.add(new QName("https://services.mathworks.com/dws3/services/DownloadService", "componentPath"));
        elementList.add(localComponentPath != null ? ((Object) (ConverterUtil.convertToString(localComponentPath))) : null);
        elementList.add(new QName("https://services.mathworks.com/dws3/services/DownloadService", "fileName"));
        elementList.add(localFileName != null ? ((Object) (ConverterUtil.convertToString(localFileName))) : null);
        elementList.add(new QName("https://services.mathworks.com/dws3/services/DownloadService", "filePath"));
        elementList.add(localFilePath != null ? ((Object) (ConverterUtil.convertToString(localFilePath))) : null);
        elementList.add(new QName("https://services.mathworks.com/dws3/services/DownloadService", "key"));
        elementList.add(ConverterUtil.convertToString(localKey));
        elementList.add(new QName("https://services.mathworks.com/dws3/services/DownloadService", "md5CheckSum"));
        elementList.add(localMd5CheckSum != null ? ((Object) (ConverterUtil.convertToString(localMd5CheckSum))) : null);
        elementList.add(new QName("https://services.mathworks.com/dws3/services/DownloadService", "name"));
        elementList.add(localName != null ? ((Object) (ConverterUtil.convertToString(localName))) : null);
        elementList.add(new QName("https://services.mathworks.com/dws3/services/DownloadService", "serverId"));
        elementList.add(localServerId != null ? ((Object) (ConverterUtil.convertToString(localServerId))) : null);
        elementList.add(new QName("https://services.mathworks.com/dws3/services/DownloadService", "size"));
        elementList.add(ConverterUtil.convertToString(localSize));
        elementList.add(new QName("https://services.mathworks.com/dws3/services/DownloadService", "sizeOnDisk"));
        elementList.add(localSizeOnDisk != null ? ((Object) (localSizeOnDisk)) : null);
        elementList.add(new QName("https://services.mathworks.com/dws3/services/DownloadService", "type"));
        elementList.add(localType != null ? ((Object) (ConverterUtil.convertToString(localType))) : null);
        elementList.add(new QName("https://services.mathworks.com/dws3/services/DownloadService", "uniqueId"));
        elementList.add(localUniqueId != null ? ((Object) (ConverterUtil.convertToString(localUniqueId))) : null);
        return new ADBXMLStreamReaderImpl(qName, elementList.toArray(), attribList.toArray());
    }

    protected ArrayOfString localArchitectureIds;
    protected String localComponentPath;
    protected String localFileName;
    protected String localFilePath;
    protected int localKey;
    protected String localMd5CheckSum;
    protected String localName;
    protected String localServerId;
    protected int localSize;
    protected ArrayOfInteger localSizeOnDisk;
    protected String localType;
    protected String localUniqueId;
}
