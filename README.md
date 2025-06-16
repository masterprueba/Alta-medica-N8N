# Proyecto: Sistema Conversacional de Alta Médica con n8n y IA

Este documento detalla el diseño, la implementación y la arquitectura de un sistema automatizado para el alta y gestión de seguros médicos. La solución utiliza n8n como plataforma de orquestación, implementando una arquitectura cliente-servidor donde un chatbot en Telegram interactúa con un agente de IA para guiar a los usuarios a través del proceso de registro.

## 1. Objetivo del Proyecto (Según `reto`)

El objetivo principal, delineado en el archivo `reto`, es diseñar un flujo en n8n para gestionar un proceso conversacional. El sistema debe ser capaz de:
*   Iniciar una conversación a través de un canal como Telegram.
*   Recopilar datos del usuario (nombre, apellido, edad, etc.) de manera guiada.
*   Utilizar un agente de IA para interpretar las respuestas y conducir la conversación de forma natural.
*   Almacenar los datos recopilados en una base de datos (Supabase).
*   Implementar validaciones de datos y confirmar la finalización del proceso.

## 2. Arquitectura de la Solución

La solución se basa en una arquitectura cliente-servidor desacoplada, implementada a través de dos flujos de trabajo de n8n distintos:

*   **`Alta Medica.json` (Cliente):** Este flujo gestiona la interfaz directa con el usuario en Telegram. Es responsable de la lógica conversacional, la validación de entradas y la experiencia de usuario.
*   **`Mcp server.json` (Servidor):** Este flujo actúa como un backend de "herramientas" para la IA. Expone funcionalidades específicas para interactuar con la base de datos (crear, leer y actualizar usuarios), que son invocadas por el cliente.

Esta separación de responsabilidades hace que el sistema sea más modular, escalable y fácil de mantener.


## 3. Componentes Detallados

### 3.1. Base de Datos (`supabase_setup2.sql`)

Se utilizó **Supabase** (PostgreSQL) como sistema de almacenamiento. El script `supabase_setup2.sql` define una estructura robusta:

*   **Tabla `usuarios_seguros`:** Almacena los datos definitivos de los clientes. Incluye campos para información personal, `user_id` de Telegram, un número de póliza, y timestamps. Es importante destacar las restricciones (`constraints`) a nivel de base de datos para validar la edad y el formato del email, añadiendo una capa extra de integridad de datos. Se habilitó `Row Level Security` (RLS) para un control de acceso más granular.
*   **Tabla `conversaciones`:** Diseñada para mantener el estado y el historial de las interacciones, guardando los datos recopilados en un campo JSONB.
*   **Índices y Triggers:** Se crearon índices para optimizar las búsquedas y un trigger (`update_updated_at`) para actualizar automáticamente la fecha de modificación de los registros.

### 3.2. Workflow Cliente (`Alta Medica.json`)

Este es el cerebro de la interacción con el usuario:

*   **Canal de Entrada:** Un **Telegram Trigger** captura los mensajes de los usuarios. El flujo maneja ingeniosamente tanto entradas de texto como de voz, utilizando el nodo **OpenAI** para transcribir audio a texto (`whisper`).
*   **Agente de IA:** El corazón del cliente es un **AI Agent** (`gpt-4o`) configurado con un prompt de sistema muy detallado. Este prompt es la clave del éxito del bot, ya que le instruye sobre:
    *   Su **personalidad** (asistente de seguro médico).
    *   El **flujo de la conversación** paso a paso (`inicio → nombre → ... → finalizado`).
    *   Cómo **manejar el contexto** y no volver a pedir datos ya proporcionados.
    *   El **formato de respuesta** (JSON estructurado) que debe devolver para ser procesado por n8n.
*   **Herramientas de Validación del Cliente:** El agente de IA tiene acceso a herramientas de código (`toolCode`) para validaciones específicas antes de enviar los datos al servidor. Esto es una excelente práctica para offloading de lógica:
    *   `validar email`: Comprueba el formato del email y si pertenece a un dominio permitido.
    *   `validar edad`: Asegura que la edad esté dentro del rango permitido (18-80).
*   **Invocación del Servidor:** Utiliza un nodo **MCP Client** para comunicarse con el workflow del servidor, pasándole los datos ya validados para que los persista en la base de datos.

### 3.3. Workflow Servidor (`Mcp server.json`)

Este flujo actúa como una API interna y segura para la base de datos.

*   **Punto de Entrada:** Un **MCP Server Trigger** escucha las peticiones del `Alta Medica.json`.
*   **Herramientas para la IA:** Expone un conjunto de herramientas claras y atómicas que el agente de IA del cliente puede invocar:
    *   `create usuarios_seguros`: Para registrar un nuevo usuario.
    *   `Get usuarios_seguros`: Para consultar la información de un usuario existente.
    *   `update usuarios_seguros`: Para modificar los datos de un usuario.
*   **Interacción con la Base de Datos:** Cada herramienta es un nodo de **Supabase** configurado para realizar una única operación (CRUD). La configuración `$fromAI(...)` en los campos es crucial, ya que ayuda al modelo de IA a mapear correctamente los datos extraídos de la conversación a las columnas de la tabla.

## 4. Retos Enfrentados y Soluciones

*   **Reto 1: Extracción Precisa de Datos y Control del Flujo.**
    *   **Problema:** Asegurar que la IA no solo extrajera los datos correctamente, sino que también siguiera la secuencia de preguntas definida.
    *   **Solución:** El diseño del **prompt del sistema** en el `AI Agent` fue la clave. Al darle instrucciones explícitas sobre el flujo (`PASOS DEL PROCESO`), el manejo de datos existentes y el formato de salida JSON, se le dio al agente un marco de trabajo rígido que minimizó las alucinaciones y el comportamiento impredecible.

*   **Reto 2: Validación de Datos Compleja.**
    *   **Problema:** Validar datos como dominios de correo específicos es propenso a errores si se deja solo a la IA.
    *   **Solución:** La creación de **herramientas de código (`toolCode`)** para validaciones específicas (`validar email`, `validar edad`) fue una decisión de diseño acertada. Esto libera a la IA para que se centre en el lenguaje natural, mientras que la lógica de negocio estricta es manejada por código determinista y confiable.

*   **Reto 3: Mantenimiento del Contexto a Largo Plazo.**
    *   **Problema:** En conversaciones largas, el agente podría perder el hilo de lo que ya se ha discutido.
    *   **Solución:** La implementación del nodo **Postgres Chat Memory** (`memoryPostgresChat`) permite que el agente tenga acceso al historial de la conversación, asegurando interacciones coherentes y fluidas.

## 5. Creatividad y Valor Añadido

*   **Arquitectura Desacoplada:** El uso de un modelo cliente-servidor dentro de n8n es una aproximación sofisticada que demuestra un profundo entendimiento de patrones de diseño de software.
*   **Experiencia de Usuario Multimodal:** Soportar tanto texto como voz como entrada de datos pone al usuario en primer lugar, ofreciendo una flexibilidad y accesibilidad notables.
*   **Inteligencia Híbrida:** La combinación de un modelo de lenguaje para la conversación y herramientas de código para la validación (IA + Código) aprovecha lo mejor de ambos mundos, creando una solución robusta y confiable.

## 6. Archivos y Demostración

*   **`Alta Medica.json`:** Workflow del cliente conversacional.
*   **`Mcp server.json`:** Workflow del servidor de herramientas de base de datos.
*   **`supabase_setup2.sql`:** Script para la configuración inicial de la base de datos.
*   **`reto`:** Descripción del desafío.

![Flujo1](https://droti.site/estructura.png)

![Flujo2](https://droti.site/Mcp.png)