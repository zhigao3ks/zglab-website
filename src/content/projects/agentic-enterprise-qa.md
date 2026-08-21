---
title: Agentic 企业知识问答系统
slug: agentic-enterprise-qa
summary: 面向企业复杂知识场景构建的多智能体问答系统，围绕检索增强、工具调用、执行链路和自动化评测建立完整 AI 应用闭环。
status: building
featured: true
visible: true
order: 2
categories: [Agent, RAG, Enterprise AI]
tags: [知识库问答, 多智能体, MCP, Evaluation]
stack: [FastAPI, LangGraph, LangChain, MCP, ChromaDB, BM25, BGE-Reranker, PostgreSQL, Redis, WebSocket]
highlights:
  - 使用 LangGraph 编排任务规划、知识检索、工具调用和结果校验流程。
  - 通过 MCP 将知识库、数据查询和外部能力封装为标准工具服务。
  - 构建文档处理、索引、混合召回和重排序 Pipeline。
  - 引入 Evaluation Harness 评估工具调用成功率、回答忠实度和完整性。
  - 关注 Agent 系统的可观测性、可靠性和工程部署。
---

## 项目背景

企业级 AI 应用不仅需要模型生成能力，还需要可靠的信息获取、工具协同和结果验证机制。本项目探索如何构建可执行、可评估的 Agent 系统。

## 系统设计

系统通过 Agent 编排用户意图识别、任务规划、知识检索和工具调用流程，并结合 RAG 技术提升复杂知识场景下的回答准确性。

## 工程实践

围绕检索质量、Agent 执行链路和回答可靠性建立评测体系，并通过服务化架构支持实际部署和持续迭代。
