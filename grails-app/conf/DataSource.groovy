dataSource {
    pooled = true
    driverClassName = "org.hsqldb.jdbcDriver"
    username = "sa"
    password = ""
}
hibernate {
    cache.use_second_level_cache = true
    cache.use_query_cache = true
    cache.provider_class = 'net.sf.ehcache.hibernate.EhCacheProvider'
}
// environment specific settings
environments {
    development {
        dataSource {
            dbCreate = "update"
		    //dbCreate = "create-drop"
		    username = "postgres"
			password = "postgres"
		    //username = "mysamuser"
			//password = "mysampassword"

			// PostgreSQL
			driverClassName = "org.postgresql.Driver"
			url = "jdbc:postgresql://localhost:5432/sam"
			dialect = org.hibernate.dialect.PostgreSQLDialect
        }
    }
    test {
        dataSource {
            dbCreate = "update"
            url = "jdbc:hsqldb:mem:testDb"
        }
    }
    production {
        dataSource {
            dbCreate = "update"
            url = "jdbc:hsqldb:file:prodDb;shutdown=true"
        }
    }
}
