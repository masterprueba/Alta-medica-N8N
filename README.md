# Sistema de Alta Médica con n8n

Este proyecto implementa un sistema automatizado de alta médica utilizando n8n como plataforma de automatización, integrando Telegram como canal de comunicación, OpenAI para el procesamiento de lenguaje natural y Supabase como base de datos.

## Descripción

El sistema permite a los usuarios realizar su alta médica a través de un bot de Telegram, guiándolos a través de un proceso conversacional inteligente. El flujo está diseñado para:

- Mantener una conversación natural y fluida con el usuario
- Recopilar información personal y médica de manera estructurada
- Validar los datos en tiempo real
- Generar un número de póliza único
- Enviar confirmación por correo electrónico con todos los detalles

## Componentes Principales

### Integración con IA (OpenAI)
- Utiliza GPT-4 para procesar y entender las respuestas del usuario
- Mantiene el contexto de la conversación
- Valida y extrae información de manera inteligente
- Guía el proceso de manera natural y conversacional

### Base de Datos (Supabase)
- Tabla `conversaciones`: Almacena el estado de las conversaciones con los usuarios
- Tabla `usuarios_seguros`: Gestiona la información de los usuarios registrados
- Funciones y triggers para mantener la integridad de los datos

### Flujo de n8n
- Integración con Telegram para la comunicación
- Proceso conversacional guiado por IA
- Validaciones de datos en tiempo real
- Generación de pólizas únicas
- Envío de confirmaciones por email
- Almacenamiento en Supabase

## Proceso Conversacional

El sistema sigue un flujo estructurado pero flexible:

1. **Inicio**: El usuario inicia la conversación
2. **Recopilación de Datos**:
   - Nombre
   - Apellido
   - Edad (18-80 años)
   - Teléfono
   - Dirección
   - Email
   - Condiciones médicas (opcional)
3. **Confirmación**: Resumen de datos y confirmación final
4. **Finalización**: Generación de póliza y envío de confirmación

## Características Especiales

- **Memoria de Conversación**: Mantiene el contexto de la conversación usando PostgreSQL
- **Validaciones Inteligentes**:
  - Formato de email
  - Rango de edad (18-80 años)
  - Campos obligatorios
- **Generación de Póliza**: Crea un número único de póliza con formato `POL-[timestamp]-[random]`
- **Confirmación por Email**: Envía un email HTML formateado con todos los detalles de la póliza
- **Prevención de Duplicados**: Verifica la existencia previa del usuario antes de crear nuevos registros

## Requisitos
- n8n instalado y configurado
- Cuenta de Supabase
- Bot de Telegram configurado
- Acceso a OpenAI API
- Servidor de correo electrónico configurado

## Configuración
1. Importar el archivo `supabase_setup2.sql` en tu base de datos Supabase
2. Importar el flujo de n8n desde `seguro_medico_workflow2.json`
3. Configurar las credenciales necesarias en n8n:
   - Telegram API
   - OpenAI API
   - Supabase
   - Servidor de correo
4. Activar el bot de Telegram

## Uso
1. El usuario inicia la conversación con el bot de Telegram
2. El sistema guía al usuario a través del proceso de alta de manera conversacional
3. Los datos se validan en tiempo real
4. Al finalizar, se genera la póliza y se envía la confirmación por email

## Seguridad
- Implementación de Row Level Security en Supabase
- Validaciones de datos en tiempo real
- Almacenamiento seguro de información sensible
- Prevención de duplicados
- Manejo seguro de credenciales en n8n


