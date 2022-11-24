/* 



*/
/*
 * 
 * 
 * 
 * 
 * 
 * 
 *
 * */

#include "std_testcase.h"

#include <winsock2.h>
#pragma comment(lib, "ws2_32")

#define LISTEN_PORT 999
#define LISTEN_BACKLOG 5
#define SECRET_HOSTNAME "www.domain.nonexistanttld"

#ifndef OMITBAD

void CWE247_Reliance_on_DNS_Lookups_in_Security_Decision__w32_01_bad()
{
    {
        WSADATA wsaData;
        BOOL wsaDataInit = FALSE;
        SOCKET listenSocket = INVALID_SOCKET;
        SOCKET client = INVALID_SOCKET;
        struct sockaddr_in service;
        struct sockaddr_in serviceClient;
        int serviceClientLen;
        struct hostent *hostInfo;
        do
        {
            if (0 != WSAStartup(MAKEWORD(2, 2), &wsaData))
            {
                break;
            }
            wsaDataInit = TRUE;
            listenSocket = socket(PF_INET, SOCK_STREAM, 0);
            if (listenSocket == INVALID_SOCKET)
            {
                break;
            }
            memset(&service, 0, sizeof(service));
            service.sin_family = AF_INET;
            service.sin_addr.s_addr = INADDR_ANY;
            service.sin_port = htons(LISTEN_PORT);
            if (SOCKET_ERROR == bind(listenSocket, (struct sockaddr*)&service, sizeof(service)))
            {
                break;
            }
            if (SOCKET_ERROR == listen(listenSocket, LISTEN_BACKLOG))
            {
                break;
            }
            serviceClientLen = sizeof(serviceClient);
            client = accept(listenSocket, (struct sockaddr*)&serviceClient, &serviceClientLen);
            if (client == INVALID_SOCKET)
            {
                break;
            }
            if (serviceClient.sin_family != AF_INET)
            {
                break;
            }
            hostInfo = gethostbyaddr((char*)&serviceClient.sin_addr, sizeof(serviceClient.sin_addr), AF_INET);
            if (hostInfo == NULL)
            {
                break;
            }
            if (hostInfo->h_name == NULL)
            {
                break;
            }
            printLine(hostInfo->h_name);
            /*  */
            /*  */
            if (strcmp(hostInfo->h_name, SECRET_HOSTNAME) == 0)
            {
                printLine("Access granted.");
            }
        }
        while (0);
        if (client != INVALID_SOCKET)
        {
            closesocket(client);
        }
        if (listenSocket != INVALID_SOCKET)
        {
            closesocket(listenSocket);
        }
        if (wsaDataInit)
        {
            WSACleanup();
        }
    }
}

#endif /* OMITBAD */

#ifndef OMITGOOD

static void good1()
{
    {
        WSADATA wsaData;
        BOOL wsaDataInit = FALSE;
        SOCKET listenSocket = INVALID_SOCKET;
        SOCKET client = INVALID_SOCKET;
        struct sockaddr_in service;
        struct sockaddr_in serviceClient;
        int serviceClientLen;
        struct hostent *hostInfo;
        FILE * pFile;
        do
        {
            if (0 != WSAStartup(MAKEWORD(2, 2), &wsaData))
            {
                break;
            }
            wsaDataInit = TRUE;
            listenSocket = socket(PF_INET, SOCK_STREAM, 0);
            if (listenSocket == INVALID_SOCKET)
            {
                break;
            }
            memset(&service, 0, sizeof(service));
            service.sin_family = AF_INET;
            service.sin_addr.s_addr = INADDR_ANY;
            service.sin_port = htons(LISTEN_PORT);
            if (SOCKET_ERROR == bind(listenSocket, (struct sockaddr*)&service, sizeof(service)))
            {
                break;
            }
            if (SOCKET_ERROR == listen(listenSocket, LISTEN_BACKLOG))
            {
                break;
            }
            serviceClientLen = sizeof(serviceClient);
            client = accept(listenSocket, (struct sockaddr*)&serviceClient, &serviceClientLen);
            if (client == INVALID_SOCKET)
            {
                break;
            }
            if (serviceClient.sin_family != AF_INET)
            {
                break;
            }
            hostInfo = gethostbyaddr((char*)&serviceClient.sin_addr, sizeof(serviceClient.sin_addr), AF_INET);
            if (hostInfo == NULL)
            {
                break;
            }
            if (hostInfo->h_name == NULL)
            {
                break;
            }
            printLine(hostInfo->h_name);
            /*  */
            pFile = fopen("log.txt", "a+");
            fprintf(pFile, "Host name: %s\n", hostInfo->h_name);
            fclose(pFile);
        }
        while (0);
        if (client != INVALID_SOCKET)
        {
            closesocket(client);
        }
        if (listenSocket != INVALID_SOCKET)
        {
            closesocket(listenSocket);
        }
        if (wsaDataInit)
        {
            WSACleanup();
        }
    }
}

void CWE247_Reliance_on_DNS_Lookups_in_Security_Decision__w32_01_good()
{
    good1();
}

#endif /* OMITGOOD */

/* 
   
   
    */

#ifdef INCLUDEMAIN

int main(int argc, char * argv[])
{
    /*  */
    srand( (unsigned)time(NULL) );
#ifndef OMITGOOD
    printLine("Calling good()...");
    CWE247_Reliance_on_DNS_Lookups_in_Security_Decision__w32_01_good();
    printLine("Finished good()");
#endif /* OMITGOOD */
#ifndef OMITBAD
    printLine("Calling bad()...");
    CWE247_Reliance_on_DNS_Lookups_in_Security_Decision__w32_01_bad();
    printLine("Finished bad()");
#endif /* OMITBAD */
    return 0;
}

#endif
