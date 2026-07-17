---
title: 面向企业知识与数据分析的 Agentic 智能问答系统
slug: agentic-enterprise-qa
summary: 面向企业复杂文档检索与跨源数据联合分析需求，构建具备多阶段混合检索、动态工具扩展、可观测 Agent 编排和自动化评测闭环的多智能体问答系统。
status: building
featured: true
visible: true
order: 1
categories: [Agent, RAG, Enterprise AI]
tags: [知识库问答, 混合检索, 自动化评测, 多智能体]
stack:
  [
    FastAPI,
    LangGraph,
    LangChain,
    MCP,
    ChromaDB,
    BM25,
    BGE-Reranker,
    PostgreSQL,
    Redis,
    WebSocket,
    vLLM,
    Qwen3,
  ]
highlights:
  - 基于 LangGraph 将用户请求拆解为意图识别、任务规划、知识检索、工具调用和事实校验节点。
  - 通过 MCP 将知识库、SQL 查询和图表生成能力封装为标准工具服务。
  - 构建文档清洗、动态切片、索引和召回 Pipeline。
  - 使用 BM25、ChromaDB 与 BGE-Reranker 实现多阶段混合检索。
  - 在项目评测口径下，专有名词查询 Top-5 召回准确率提升约 40%，答案采纳率提升 35% 以上。
  - 搭建 Evaluation Harness，对工具调用成功率、回答忠实度和完整性进行评测。
  - 基于 vLLM 本地部署 Qwen3 作为 LLM-as-a-Judge。
  - 使用 FastAPI、WebSocket、PostgreSQL 和 Redis 完成服务化。
---

## 问题定义

企业知识问答不仅需要从复杂文档中找到相关内容，还要处理跨源数据联合分析、工具调用与结果校验。该项目围绕检索质量、Agent 执行链路和回答可靠性构建完整闭环。

## 系统链路

系统使用 LangGraph 编排意图识别、任务规划、知识检索、工具调用和事实校验节点，并通过 MCP 将知识库、SQL 查询和图表生成能力封装为标准工具服务。

检索链路覆盖文档清洗、动态切片、索引、BM25 与 ChromaDB 混合召回，以及 BGE-Reranker 重排序。

## 评测与服务化

Evaluation Harness 用于评测工具调用成功率、回答忠实度和完整性。项目基于 vLLM 本地部署 Qwen3 作为 LLM-as-a-Judge，并通过 FastAPI、WebSocket、PostgreSQL 与 Redis 完成服务化。
