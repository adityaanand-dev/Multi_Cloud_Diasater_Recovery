# =============================================================================
# Frontend - Nginx serving static content
# Multi-Cloud Disaster Recovery POC
# =============================================================================
FROM nginx:1.25-alpine

# Copy custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy static content
COPY html/ /usr/share/nginx/html/

# Health check endpoint
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -q --spider http://localhost/health || exit 1

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
